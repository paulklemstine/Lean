# Power-Sum GCD Factoring and Carmichael Periodicity

**A complete spectral read-out of the prime factors of a squarefree modulus**

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

For a modulus $N$ and an exponent $k$, let

$$F(N,k) \;=\; \sum_{a=1}^{N} a^{k}$$

be the $k$-th power sum over a complete residue system modulo $N$. We prove that the single quantity $g_N(k) = \gcd(F(N,k), N)$ is an exact, deterministic read-out of the multiplicative structure of $N$. Our central result is a closed product formula: for squarefree $N$ and $k > 0$,

$$\gcd\big(F(N,k),\,N\big) \;=\; \prod_{\substack{r \text{ prime},\ r \mid N\\ (r-1)\,\nmid\, k}} r,$$

which reduces the entire phenomenon to the classical dichotomy $\sum_{x\in\mathbb F_p} x^k \in \{-1,0\}$ over a prime field. From it we deduce: (i) a **factor-reveal theorem** — for distinct primes $p,q$ with $(q-1)\nmid(p-1)$ one has $\gcd(F(pq,p-1),pq)=q$ exactly, with no base parameter and no failure probability; (ii) a **robustness theorem** — for any two distinct odd primes and any even exponent, Pollard's $p-1$ step admits a base returning the whole modulus, a failure mode the power sum structurally cannot have; (iii) a **Carmichael periodicity theorem** — $g_N$ is periodic with least period exactly $\lambda(N)=\operatorname{lcm}_{r\mid N}(r-1)$, with $g_N(k)=1$ if and only if $\lambda(N)\mid k$, and with the term-wise Korselt congruence $F(N,k+\lambda(N))\equiv F(N,k)\pmod N$; (iv) a **Giuga-type closed form** — $F(N,k)\equiv-\sum_{(r-1)\mid k}N/r \pmod N$, generalising $\sum_{a=1}^{p-1}a^{p-1}\equiv-1\pmod p$; and (v) a **lattice anti-homomorphism law** — $g_N(\gcd(k,k'))=\operatorname{lcm}(g_N(k),g_N(k'))$.

We also analyse the cost. For a semiprime $N=pq$ the read-out is uninformative ($g_N(k)=N$) for all $0<k<\min(p-1,q-1)$ and first drops below $N$ exactly at $k=\min(p-1,q-1)\approx\sqrt N$; with $O(N)$ work per evaluation this yields $O(N^{3/2})$, worse than trial division. Finally we correct a natural but false recovery identity: $p+q=N-\lambda(N)+1$ fails for *every* product of two distinct odd primes; the correct statement is $p+q+\lambda(N)\gcd(p-1,q-1)=N+1$, and the naive version always strictly overshoots (witness $N=15$: predicted $12$, true $8$). The residual unknown $\gcd(p-1,q-1)$ isolates, as a single explicit quantity, what period-finding alone does not deliver.

**Keywords:** power sums, Fermat's little theorem, Carmichael function, Korselt's criterion, Giuga's conjecture, integer factorisation, Pollard $p-1$, period finding.

---

## 1. Introduction

### 1.1 The object of study

Let $N \geq 1$ and $k \geq 0$ be integers, and define the **power sum**

$$F(N,k) \;=\; \sum_{a=1}^{N} a^{k}.$$

The set $\{1,2,\dots,N\}$ is a complete residue system modulo $N$, so $F(N,k)$ modulo $N$ is a canonical invariant: it does not depend on how we enumerate residues. This makes $F(N,k) \bmod N$ a natural candidate for extracting arithmetic information about $N$ — and it does so, completely.

The quantity we study is the **read-out**

$$g_N(k) \;=\; \gcd\big(F(N,k),\,N\big),$$

a divisor of $N$ for every $k$. Because $F(N,k)$ mixes together all residues, the read-out has no free parameters — no base, no seed, no randomness. This turns out to be both its structural strength and, from a computational standpoint, its irrelevance.

### 1.2 Motivating experiment

For $N = 15 = 3\cdot 5$ and $N = 35 = 5\cdot 7$ the read-out sequences $g_N(1), g_N(2), \dots$ begin

$$
\begin{array}{c|ccccccccccccc}
k & 1&2&3&4&5&6&7&8&9&10&11&12&13\\\hline
g_{15}(k) & 15&5&15&1&15&5&15&1&15&5&15&1&15\\
g_{35}(k) & 35&35&35&7&35&5&35&7&35&35&35&1&35
\end{array}
$$

Three features are visible: nontrivial factors appear at specific exponents ($5$ at $k=2$ for $N=15$; $7$ at $k=4$ and $5$ at $k=6$ for $N=35$); the value $1$ occurs exactly at multiples of $4$, respectively of $12$; and the sequences are periodic with those same periods. Since $\operatorname{lcm}(3-1,5-1)=4$ and $\operatorname{lcm}(5-1,7-1)=12$, the period is the Carmichael exponent. Everything below is an explanation and a proof of these observations, in complete generality.

### 1.3 Relation to existing methods

Pollard's $p-1$ method computes $\gcd(a^M-1,N)$ for a base $a$ and a smooth exponent $M$, succeeding when $M$ is a multiple of the order of $a$ modulo one prime factor but not the other. Its structure is: sample the multiplicative group at one point, test whether the sample has become trivial. The power-sum read-out replaces the sample by the *integral*: rather than testing a single $a$, it aggregates all $a$, and Fermat's little theorem does the rest. The gain is the elimination of the bad-base failure mode (Theorem 5.2 below); the loss is that a single evaluation costs $O(N)$ rather than $O(\log M \log^2 N)$.

The read-out is also intimately connected to primality: its exact residue (Theorem 6.2) is a Giuga-type congruence, and on the trivial locus of the read-out the criterion "$F(N,k)\equiv -1$" becomes precisely Giuga's condition $\sum_{r\mid N} N/r \equiv 1 \pmod N$.

### 1.4 Organisation

Section 2 fixes notation and establishes the counting lemma and the finite-field dichotomy. Section 3 proves the divisibility criterion and the semiprime gcd formula, including the factor-reveal theorem. Section 4 gives the general squarefree product formula and the first-hit analysis. Section 5 treats robustness against Pollard bad bases. Section 6 gives the Giuga closed form. Section 7 proves Carmichael periodicity, minimality of the period, and corrects the naive recovery identity. Section 8 discusses algorithms and complexity, Section 9 applications and interpretation, Section 10 open problems.

---

## 2. Preliminaries

Throughout, $p,q,r$ denote primes, $N,k,L,a$ non-negative integers, and $\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$. We write $\lambda(N) = \operatorname{lcm}\{\,r-1 : r \text{ prime},\ r \mid N\,\}$ for the Carmichael exponent of a squarefree $N$; for a semiprime $N = pq$ this is $\lambda(N) = \operatorname{lcm}(p-1,q-1)$. We say $N$ is *squarefree* if no prime square divides it.

**Definition 2.1 (Power sum).** $F(N,k) = \sum_{a=1}^{N} a^{k}$.

Two immediate identities, both proved by induction on $N$, will be used silently: $F(0,k)=0$, $F(N+1,k)=F(N,k)+(N+1)^k$, and for $k>0$,

$$F(N,k) \;=\; \Big(\sum_{a=0}^{N-1} a^{k}\Big) + N^{k},$$

which lets us pass from the interval $[1,N]$ to the interval $[0,N-1]$ of canonical residues at the cost of an explicit top term.

**Lemma 2.2 (Uniform covering).** Let $p \geq 1$, let $R$ be an additive commutative monoid and $f : \mathbb{Z}/p\mathbb{Z} \to R$ any function. Then for every $n \geq 0$,

$$\sum_{a=0}^{pn-1} f(a \bmod p) \;=\; n \cdot \sum_{x \in \mathbb{Z}/p\mathbb{Z}} f(x).$$

*Proof.* Induction on $n$. For the step, split $[0, p(n+1))$ into $[0,pn)$ and the block $[pn, pn+p)$; the latter is a complete set of residues mod $p$, so summing $f$ over it gives $\sum_x f(x)$ by re-indexing the canonical representatives. $\square$

This is the entire "geometric" content of the theory: *the interval $[1,N]$ covers each residue class modulo any divisor of $N$ equally often.*

**Lemma 2.3 (Complete power sum over a prime field).** Let $p$ be prime and $k > 0$. Then

$$\sum_{x \in \mathbb{F}_p} x^{k} \;=\; \begin{cases} -1 & \text{if } (p-1)\mid k,\\ \ \ 0 & \text{otherwise.}\end{cases}$$

*Proof sketch.* Since $k>0$, the term $x=0$ contributes $0$, so the sum equals $\sum_{x \in \mathbb{F}_p^{\times}} x^k$ over the cyclic group of order $p-1$. If $(p-1)\mid k$, every term is $1$ by Fermat, giving $p-1 \equiv -1$. Otherwise, pick a generator $\zeta$; the sum is the geometric series $\sum_{j=0}^{p-2}\zeta^{jk} = (\zeta^{k(p-1)}-1)/(\zeta^{k}-1) = 0$, the denominator being nonzero exactly because $(p-1)\nmid k$. $\square$

---

## 3. The divisibility criterion and the semiprime formula

**Theorem 3.1 (Reduction modulo a prime factor).** Let $p$ be prime, $q \geq 0$ an integer and $k>0$. Then

$$F(pq,\,k) \;\equiv\; q\cdot\begin{cases}-1 & (p-1)\mid k\\ \ \ 0 & \text{else}\end{cases} \pmod p .$$

*Proof.* Write $F(pq,k) = \sum_{a=0}^{pq-1}a^k + (pq)^k$. The top term is $\equiv 0$ since $k > 0$ and $p \mid pq$. By Lemma 2.2 with $f(x)=x^k$ and $n=q$, the remaining sum is $q\sum_{x\in\mathbb{F}_p}x^k$, and Lemma 2.3 evaluates the inner sum. $\square$

**Theorem 3.2 (Divisibility criterion).** Let $p$ be prime, $p \nmid q$, and $k>0$. Then

$$p \mid F(pq,k) \iff (p-1)\nmid k.$$

*Proof.* By Theorem 3.1, $F(pq,k) \equiv -q$ or $0$ modulo $p$ according as $(p-1)\mid k$ or not. In the first case $-q \not\equiv 0$ because $p \nmid q$; in the second the sum is $\equiv 0$. $\square$

This criterion is exact: no error term, no exceptional set. It is the pivot on which everything else turns.

**Lemma 3.3.** For $p$ prime, $\gcd(a,p) = p$ if $p \mid a$ and $1$ otherwise.

**Theorem 3.4 (Semiprime gcd formula).** Let $p \neq q$ be primes and $k>0$. Then

$$\gcd\big(F(pq,k),\,pq\big) \;=\; \Big(\text{if } (p-1)\mid k \text{ then } 1 \text{ else } p\Big)\cdot\Big(\text{if } (q-1)\mid k \text{ then } 1 \text{ else } q\Big).$$

*Proof.* Since $p,q$ are coprime, $\gcd(x,pq)=\gcd(x,p)\gcd(x,q)$. Apply Lemma 3.3 and Theorem 3.2 to each factor (for the $q$-factor, use $F(pq,k)=F(qp,k)$). $\square$

**Corollary 3.5 (Non-triviality dichotomy).** The gcd in Theorem 3.4 is a proper nontrivial divisor of $pq$ if and only if exactly one of $(p-1)\mid k$, $(q-1)\mid k$ holds; it equals $1$ if both hold, and $pq$ if neither does.

**Theorem 3.6 (Factor reveal).** Let $p\neq q$ be primes with $(q-1)\nmid(p-1)$. Then

$$\gcd\big(F(pq,\,p-1),\,pq\big) \;=\; q,$$

and this value is a proper nontrivial divisor: $1 < q < pq$.

*Proof.* Set $k=p-1>0$. Then $(p-1)\mid k$ trivially and $(q-1)\nmid k$ by hypothesis, so Theorem 3.4 gives $1\cdot q = q$. Properness: $q>1$ as $q$ is prime and $q = 1\cdot q < p\cdot q$ as $p>1$. $\square$

The hypothesis $(q-1)\nmid(p-1)$ is genuinely needed and not restrictive: it fails only when $q-1$ divides $p-1$, in which case the symmetric exponent $k = q-1$ works instead unless $(p-1)\mid(q-1)$ as well — which for $p \neq q$ forces $p-1=q-1$, i.e. $p=q$, excluded. Hence for every semiprime at least one of $k = p-1$, $k=q-1$ reveals a factor. Concretely, for the pairs $(3,5),(3,7),(5,7),(5,11),(7,13),(11,13),(13,17),(97,101)$ the exponent $k=p-1$ returns $5,7,7,11,13,13,17,101$ respectively — the larger prime, every time.

**Theorem 3.7 (Carmichael coprimality criterion).** Let $N$ be squarefree and $k>0$. Then $F(N,k)$ is coprime to $N$ if and only if $(r-1)\mid k$ for every prime $r\mid N$.

*Proof.* ($\Rightarrow$) If some prime $r\mid N$ has $(r-1)\nmid k$, write $N=rm$ with $r\nmid m$ (possible by squarefreeness); Theorem 3.2 gives $r \mid F(N,k)$, so $r$ divides the gcd, contradicting coprimality. ($\Leftarrow$) If the gcd exceeds $1$, some prime $r$ divides both $F(N,k)$ and $N$; splitting $N=rm$ again, Theorem 3.2 forces $(r-1)\nmid k$. $\square$

The right-hand condition is exactly the Korselt-type condition that defines the Carmichael exponent; this is the first appearance of $\lambda(N)$.

---

## 4. The general squarefree product formula

**Lemma 4.1 (gcd against a squarefree modulus).** Let $N$ be squarefree and $a$ any integer. Then

$$\gcd(a,N) \;=\; \prod_{\substack{r \mid N \text{ prime}\\ r \mid a}} r .$$

*Proof sketch.* For squarefree $N$, $N = \prod_{r \mid N} r$ with distinct primes. Induction over subsets of the prime factors, using multiplicativity of the gcd against pairwise coprime factors, reduces to Lemma 3.3 for each prime. $\square$

**Theorem 4.2 (Product formula — main structural result).** Let $N$ be squarefree and $k>0$. Then

$$\gcd\big(F(N,k),\,N\big) \;=\; \prod_{\substack{r \mid N \text{ prime}\\ (r-1)\,\nmid\, k}} r .$$

*Proof.* By Lemma 4.1 the gcd is the product over primes $r\mid N$ with $r \mid F(N,k)$. Fix such an $r$ and write $N=rm$ with $r\nmid m$ (squarefreeness). By Theorem 3.2 the condition $r\mid F(N,k)$ is equivalent to $(r-1)\nmid k$. The two index sets coincide. $\square$

Theorem 4.2 says the read-out is a **spectral filter**: the exponent $k$ deletes precisely those primes whose order condition $(r-1)\mid k$ is satisfied, and displays the product of the survivors. Theorem 3.4 is the case of two prime factors.

**Definition 4.3.** For squarefree $N$, the Carmichael exponent is $\lambda(N) = \operatorname{lcm}_{r \mid N}(r-1)$. For a semiprime $N=pq$ this specialises to $\operatorname{lcm}(p-1,q-1)$.

**Theorem 4.4 (Trivial locus).** Let $N$ be squarefree and $k>0$. Then $\gcd(F(N,k),N)=1$ if and only if $\lambda(N)\mid k$.

*Proof.* By Theorem 3.7 the gcd is $1$ iff $(r-1)\mid k$ for all primes $r \mid N$, and by the universal property of the lcm this is exactly $\lambda(N) \mid k$. $\square$

**Theorem 4.5 (Uninformative range and first hit).** Let $p \neq q$ be primes and $N=pq$.
1. $\gcd(F(N,k),N)=N$ if and only if $(p-1)\nmid k$ and $(q-1)\nmid k$.
2. For every $k$ with $0<k<\min(p-1,q-1)$ we have $\gcd(F(N,k),N)=N$: the read-out carries no information.
3. At $k=\min(p-1,q-1)$ we have $\gcd(F(N,k),N)\neq N$.

*Proof.* (1) is Corollary 3.5. (2) If $(p-1)\mid k$ with $k>0$, then $p-1 \leq k < \min(p-1,q-1) \leq p-1$, a contradiction; symmetrically for $q$. (3) At $k=\min(p-1,q-1)$, whichever of $p-1$, $q-1$ attains the minimum divides $k$, so by (1) the gcd is not $N$. $\square$

So the smallest informative exponent is *exactly* $\min(p-1,q-1)$ — for a balanced semiprime, about $\sqrt N$. This is the source of the complexity barrier quantified in Section 8.

**Theorem 4.6 (Lattice anti-homomorphism).** Let $N$ be squarefree and $k,k'>0$. Then

$$g_N\big(\gcd(k,k')\big) \;=\; \operatorname{lcm}\big(g_N(k),\,g_N(k')\big), \qquad g_N(k) := \gcd(F(N,k),N).$$

*Proof.* By Theorem 4.2 each side is a product of distinct primes dividing $N$. A prime $r$ occurs on the left iff $(r-1)\nmid\gcd(k,k')$, i.e. iff $(r-1)\nmid k$ **or** $(r-1)\nmid k'$ — the survival sets combine by union. For finsets of distinct primes, the product over a union is the lcm of the products, giving the right-hand side. $\square$

**Corollary 4.7 (Monotonicity).** If $k \mid k'$ with $k,k'>0$ then $g_N(k')\mid g_N(k)$: refining the exponent can only shrink the revealed divisor.

**Corollary 4.8.** The trivial locus is closed under gcd: if $g_N(k)=g_N(k')=1$ then $g_N(\gcd(k,k'))=1$. Dually, if $g_N(\gcd(k,k'))=N$ then $\operatorname{lcm}(g_N(k),g_N(k'))=N$.

Thus $g_N$ is an order-reversing lattice morphism from the divisibility lattice of exponents to the divisor lattice of $N$. This is the structural reason to expect (Conjecture 10.1) that the minimal nontrivial values of the read-out are exactly the co-factors $N/r$.

---

## 5. Robustness: the absence of bad bases

Pollard's $p-1$ step is the map $(a,M)\mapsto \gcd(a^M-1,N)$. It fails — returns $N$, revealing nothing — exactly when $a^M\equiv 1$ modulo every prime factor of $N$.

**Lemma 5.1.** For $s\geq 1$ and $M$ even, $s^{M}\equiv 1 \pmod{s+1}$.

*Proof.* $s \equiv -1 \pmod{s+1}$, so $s^2 \equiv 1$, and $M=2t$ gives $s^M=(s^2)^t\equiv 1$. $\square$

**Theorem 5.2 (Pollard bad bases always exist).** Let $p\neq q$ be distinct odd primes and $M>0$ even. Then there exists $a$ with $1<a<pq$ and

$$\gcd\big(a^{M}-1,\ pq\big) \;=\; pq .$$

*Proof.* By the Chinese Remainder Theorem choose $a$ with $1 < a < pq$, $a\equiv 1 \pmod p$ and $a \equiv q-1 \equiv -1 \pmod q$. (That $a \neq 0,1$ follows because $a\equiv 1 \pmod p$ rules out $a\equiv -1 \pmod q$ being $0$ or $1$ for odd $q\geq 3$.) Then $a^M \equiv 1^M = 1 \pmod p$, and $a^M\equiv (q-1)^M \equiv 1 \pmod q$ by Lemma 5.1 with $s=q-1$. By CRT, $a^M\equiv 1 \pmod{pq}$, i.e. $pq \mid a^M-1$, whence the gcd is $pq$. $\square$

**Theorem 5.3 (Robustness of the power sum).** Let $p\neq q$ be distinct odd primes with $(q-1)\nmid(p-1)$. Then simultaneously:

$$\gcd\big(F(pq,\,p-1),\,pq\big) = q, \qquad\text{and}\qquad \exists\, a,\ 1<a<pq,\ \gcd\big(a^{p-1}-1,\,pq\big)=pq .$$

*Proof.* The first is Theorem 3.6. For the second, $p-1$ is even (as $p$ is an odd prime), so Theorem 5.2 applies with $M=p-1$. $\square$

The smallest instance is $N=15$, $M=2$, $a=4$: $\gcd(4^2-1,15)=\gcd(15,15)=15$ — a complete failure of Pollard's step — while $\gcd(F(15,2),15)=\gcd(1240,15)=5$.

The conceptual point is not that the power sum is *better* (it is far slower); it is that the failure mode is *structurally absent*. Pollard's method has a parameter, and the parameter space contains fixed points of the test; the power sum has no parameter, because it sums over all of them at once.

---

## 6. The exact residue: a Giuga-type closed form

The divisibility criterion says whether a prime divides $F(N,k)$. One can determine the exact residue modulo $N$.

**Lemma 6.1.** Let $N$ be squarefree, $r_0 \neq r$ distinct primes dividing $N$. Then $r_0 \mid N/r$.

*Proof.* Write $N=rm$; then $N/r = m$, and $r_0 \mid rm$ with $r_0 \neq r$ prime forces $r_0\mid m$. $\square$

**Theorem 6.2 (Giuga-type closed form).** Let $N$ be squarefree and $k>0$. Then

$$F(N,k) \;\equiv\; -\!\!\sum_{\substack{r\mid N \text{ prime}\\ (r-1)\mid k}} \frac{N}{r} \pmod N .$$

*Proof.* Since $N$ is squarefree, it suffices to verify the congruence modulo each prime $r_0 \mid N$. Write $N=r_0m$ with $r_0\nmid m$. By Theorem 3.1, $F(N,k)\equiv -m = -N/r_0$ modulo $r_0$ if $(r_0-1)\mid k$, and $\equiv 0$ otherwise. On the right-hand side, every summand $N/r$ with $r\neq r_0$ vanishes modulo $r_0$ by Lemma 6.1; the summand $N/r_0$ is present exactly when $(r_0-1)\mid k$. The two sides agree in both cases. $\square$

**Corollary 6.3 (Giuga's sum for a prime).** For $p$ prime, $F(p,p-1) + 1 \equiv 0 \pmod p$, i.e. $\sum_{a=1}^{p-1}a^{p-1}\equiv -1 \pmod p$.

*Proof.* Take $N=p$, $k=p-1$: the only prime factor is $p$ and $(p-1)\mid(p-1)$, so the sum on the right is $N/p=1$. $\square$

**Corollary 6.4 (Giuga criterion form).** For squarefree $N$ and $k>0$,

$$F(N,k)\equiv -1 \pmod N \iff \sum_{\substack{r\mid N\\ (r-1)\mid k}} \frac{N}{r}\ \equiv\ 1 \pmod N .$$

In particular, when $\lambda(N)\mid k$ the condition on the right is over *all* primes $r\mid N$ and reads $\sum_{r\mid N} N/r \equiv 1 \pmod N$ — precisely Giuga's condition. So the power-sum read-out contains a primality criterion of Giuga type as the special case "evaluate on the trivial locus".

A numerical instance: $N=35$, $k=12=\lambda(35)$. Both $4\mid 12$ and $6\mid 12$, so the formula predicts $F(35,12)\equiv -(35/5+35/7)=-(7+5)=-12\equiv 23\pmod{35}$; direct computation confirms $F(35,12)\bmod 35=23$.

---

## 7. Carmichael periodicity, minimality, and factor recovery

**Lemma 7.1 (Prime-level periodicity).** Let $p$ be prime, $k>0$ and $(p-1)\mid L$. Then $a^{k+L}\equiv a^{k} \pmod p$ for every integer $a$.

*Proof.* If $p\mid a$ both sides are $0$ (here $k>0$ is essential). Otherwise $a$ is a unit and $a^{p-1}\equiv 1$, so $a^L\equiv 1$ and $a^{k+L}=a^ka^L\equiv a^k$. $\square$

**Theorem 7.2 (Korselt periodicity of the power sum).** Let $N$ be squarefree, $k>0$, and let $L$ satisfy $(r-1)\mid L$ for every prime $r\mid N$ (e.g. $L = \lambda(N)$). Then

$$F(N,k+L)\;\equiv\;F(N,k) \pmod N .$$

*Proof.* By Lemma 7.1 the congruence $a^{k+L}\equiv a^k$ holds modulo every prime factor of $N$; since $N$ is squarefree and its prime factors are pairwise coprime, CRT lifts it to modulus $N$. Summing over $a=1,\dots,N$ preserves congruences. $\square$

This is Korselt's criterion in aggregated form: the very congruence $a^{k+\lambda}\equiv a^k \pmod N$ that characterises Carmichael numbers, summed over a complete residue system.

**Theorem 7.3 (Periodicity of the read-out).** For distinct primes $p,q$, $N=pq$ and $k>0$,

$$g_N(k+\lambda(N)) \;=\; g_N(k).$$

*Proof.* By Theorem 3.4, $g_N(k)$ depends on $k$ only through the truth values of $(p-1)\mid k$ and $(q-1)\mid k$. Since $(p-1)\mid\lambda(N)$, we have $(p-1)\mid k+\lambda(N)$ iff $(p-1)\mid k$, and similarly for $q$. $\square$

**Theorem 7.4 (Minimality of the period).** Let $p\neq q$ be primes, $N=pq$, and suppose $d \geq 0$ satisfies $g_N(k+d)=g_N(k)$ for all $k>0$. Then $\lambda(N)\mid d$. Consequently, if $d>0$ then $\lambda(N)\leq d$: the Carmichael exponent is the *least* positive period.

*Proof.* Put $k=\lambda(N)>0$. By Theorem 4.4, $g_N(\lambda(N))=1$. The periodicity hypothesis gives $g_N(\lambda(N)+d)=1$, so Theorem 4.4 applied at the positive exponent $\lambda(N)+d$ gives $\lambda(N)\mid \lambda(N)+d$, hence $\lambda(N)\mid d$. $\square$

Theorems 7.3 and 7.4 together say: **$\lambda(N)$ is observable.** It is not encoded in the read-out in a statistical or approximate way; it *is* the minimal period of an explicitly defined integer sequence. For a cryptographic modulus, $\lambda(N)$ is as secret as the factorisation. So the read-out places the secret in a completely transparent location — and the entire difficulty of exploiting it is the difficulty of *measuring a period*.

### 7.1 From $\lambda(N)$ to the factorisation: an honest accounting

Suppose an oracle hands us $N=pq$ and $\lambda(N)$. Does the factorisation follow? A natural guess is that $\lambda(N)=(p-1)(q-1)=N-(p+q)+1$, giving

$$p+q \;=\; N-\lambda(N)+1. \tag{$\star$}$$

**This is false.** The Carmichael exponent is the *lcm*, not the product.

**Theorem 7.5 (Correct recovery identity).** For any primes $p,q$,

$$p+q+\lambda(N)\cdot\gcd(p-1,q-1) \;=\; N+1, \qquad N=pq.$$

*Proof.* Write $p=a+1$, $q=b+1$. Then $\gcd(a,b)\operatorname{lcm}(a,b)=ab$, and
$p+q+\operatorname{lcm}(a,b)\gcd(a,b) = (a+1)+(b+1)+ab = (a+1)(b+1)+1 = N+1$. $\square$

**Theorem 7.6 (The naive formula always overshoots).** If $p\neq q$ are odd primes then

$$p+q+\lambda(N) \;<\; N+1,$$

so $(\star)$ strictly overestimates $p+q$.

*Proof.* Both $p-1$ and $q-1$ are even, so $g := \gcd(p-1,q-1)\geq 2$. By Theorem 7.5, $p+q = N+1-\lambda(N)g \leq N+1-2\lambda(N) < N+1-\lambda(N)$, using $\lambda(N)>0$. $\square$

**Example 7.7.** $N=15=3\cdot 5$: $\lambda(15)=\operatorname{lcm}(2,4)=4$, so $(\star)$ predicts $p+q=15-4+1=12$, while in fact $p+q=8$. Here $g=\gcd(2,4)=2$ and Theorem 7.5 reads $8+4\cdot 2 = 16 = 15+1$. ✓

The consequence is conceptually important. Knowing $(N,\lambda(N))$ leaves *exactly one* unknown, namely $g=\gcd(p-1,q-1)$: given $g$ we get $p+q = N+1-\lambda(N)g$ and hence $p,q$ as roots of $x^2-(p+q)x+N$. Since $g$ is a divisor of $\lambda(N)$, one could in principle enumerate; but $g$ ranges over an unbounded set as $p,q$ vary, and the enumeration is bounded only by the divisor count of $\lambda(N)$. Theorem 7.5 thereby converts a vague "period-finding barrier" into a single, explicitly named missing quantity.

---

## 8. Algorithms and complexity

### 8.1 The read-out algorithm

**Algorithm A (Power-sum read-out).** Input $N$, $k$. Compute $S \leftarrow \sum_{a=1}^{N} a^k \bmod N$ using modular exponentiation for each term, then return $\gcd(S,N)$.

Cost: $N$ modular exponentiations, each $O(\log k)$ multiplications of $O(\log N)$-bit numbers, i.e. $\tilde O(N\log k)$ bit-operations. Space $O(\log N)$.

**Algorithm B (Factor search).** For $k=1,2,3,\dots$ compute $d = \gcd(F(N,k)\bmod N,\,N)$ and report $d$ whenever $1<d<N$.

By Theorem 4.5 the first report happens exactly at $k^{*}=\min(p-1,q-1)$ for a semiprime $N=pq$. For balanced semiprimes $k^{*}\approx\sqrt N$, so Algorithm B costs $\tilde O(N\cdot\sqrt N)=\tilde O(N^{3/2})$ — worse than trial division's $\tilde O(\sqrt N)$ by a factor of $N$. Algorithm B is therefore of structural, not practical, interest: it is a *proof* that a deterministic, base-free, always-correct factor extractor exists, at a price.

**Algorithm C (Carmichael read).** Compute $g_N(k)$ for $k=1,\dots,K$; the minimal period of the resulting sequence is $\lambda(N)$ provided $K\geq 2\lambda(N)$ (Theorems 7.3–7.4 guarantee the period is exactly $\lambda(N)$, so any observed period is a multiple of it and the minimal observed period over a sufficiently long window is exact). Equivalently, by Theorem 4.4, $\lambda(N)$ is the smallest $k>0$ with $g_N(k)=1$.

**Algorithm D (Recovery from $(N,\lambda)$).** For each divisor $g$ of $\lambda(N)$, set $s=N+1-\lambda(N)g$ and test whether $x^2-sx+N$ has integer roots; accept when the roots are prime and multiply to $N$. Theorem 7.5 guarantees success at $g=\gcd(p-1,q-1)$; Theorem 7.6 guarantees $g=1$ never works for odd semiprimes. Cost: $O(\tau(\lambda(N)))$ integer square roots.

### 8.2 Where the cost lives

Three facts fix the complexity profile.

1. *Per-evaluation cost is linear in $N$* because the sum has $N$ terms and no closed form modulo a composite $N$ is available without knowing the factorisation. (Faulhaber's formula expresses $F(N,k)$ as a polynomial in $N$ with Bernoulli-number coefficients, but those coefficients have denominators divisible by the very primes one is hunting — von Staudt–Clausen — so the polynomial evaluation cannot be carried out modulo $N$ without further information.)
2. *The first informative exponent is $\min(p-1,q-1)$*, exactly (Theorem 4.5), so no early-exit heuristic can help.
3. *The information is in the period*, and reading a period of length $\approx\sqrt N$ by sequential sampling costs $\approx\sqrt N$ samples.

Item 3 is the same structural situation exploited by Shor's algorithm, which factors by finding the period of $x\mapsto a^x \bmod N$ using a quantum Fourier transform, and which is polynomial-time precisely because it does not need to sample the period sequentially. The power-sum read-out is a fully classical object with the same information-theoretic shape: the secret sits in a period, and classically one pays for the period.

---

## 9. Discussion and applications

**A parameter-free factoring probe.** The results give a factoring probe that is deterministic, has no base or seed, and never returns a false answer: by Theorem 3.6, $\gcd(F(pq,p-1),pq)=q$ on the nose. Compared with Pollard $p-1$, the trade is a guaranteed answer at a much higher cost. Theorem 5.3 makes the comparison sharp: at the exact exponent where the power-sum probe succeeds, Pollard's probe has an explicit failing base.

**A Carmichael/Korselt lens.** Theorem 4.4 says that $F(N,k)$ is coprime to $N$ exactly on the multiples of $\lambda(N)$, and Theorem 7.2 gives the aggregated Korselt congruence. So the power-sum read-out is, in a precise sense, a *detector for Carmichael-type structure*: a composite $N$ behaves "prime-like" for the read-out exactly when $k$ hits the Carmichael exponent.

**A Giuga lens.** Corollary 6.4 exhibits Giuga's condition $\sum_{r\mid N}N/r\equiv 1\pmod N$ as the specialisation of the read-out's exact residue to the trivial locus, tying a factoring probe to a classical primality criterion.

**A lattice invariant.** Theorem 4.6 says the read-out intertwines gcd of exponents with lcm of divisors. In particular the multiset of values $\{g_N(k)\}$ is closed under lcm, and the algebraic structure of $N$'s divisor lattice is reflected — order-reversingly — in the read-out's image.

**Pedagogical value.** The whole development rests on two elementary facts (uniform covering of residues; the $-1/0$ dichotomy of complete power sums over $\mathbb F_p$), and from them recovers Fermat, Korselt, Giuga, Carmichael, and a clean statement of the period-finding barrier. It is an unusually short path from first principles to the frontier of what classical factoring can and cannot do.

**Caution.** None of this is a factoring breakthrough, and the paper does not claim one. The honest headline is the opposite: a completely transparent encoding of the factorisation exists, and it is still useless classically, for reasons Theorem 4.5, the linear per-term cost, and Theorem 7.6 make precise.

---

## 10. Open problems and future directions

**Conjecture 10.1 (gcd-lattice reconstruction).** For squarefree $N$, the family $\{\,g_N(k) : 1\le k\le\lambda(N)\,\}$ is closed under lcm, and its set of *minimal* nontrivial members is exactly $\{\,N/r : r \text{ prime},\ r\mid N\,\}$. Hence the full factorisation of $N$ is a lattice-theoretic invariant of the single sequence $k\mapsto g_N(k)$.

The motivation is Theorem 4.6: $g_N$ is an order-reversing morphism from the gcd-lattice of exponents to the divisor lattice of $N$, so the atoms of the image lattice ought to be the co-atoms of the divisor lattice. Reducing the conjecture to a finite lattice argument requires only a Dirichlet-type non-emptiness statement: for each prime $r\mid N$ there is $k\leq\lambda(N)$ with $(r'-1)\mid k$ for all $r'\neq r$ and $(r-1)\nmid k$.

**Conjecture 10.2 (the $\gcd(p-1,q-1)$ barrier is intrinsic).** There is no function $\Phi$ computable in time $\mathrm{polylog}(N)$ from the pair $(N,\lambda(N))$ alone that outputs $p+q$ for all semiprimes $N=pq$: infinitely many pairs share the same $(N,\lambda)$ profile modulo the ambiguity $g=\gcd(p-1,q-1)$.

The motivation is Theorem 7.5: $\lambda(N)$ determines $(p-1)(q-1)$ only up to the factor $g$, and $g$ ranges over an unbounded set as $p,q$ vary, so the map $(N,\lambda)\mapsto p+q$ is information-theoretically underdetermined rather than merely computationally hard. Theorem 7.5 isolates $g$ as the *only* missing quantity, turning the vague "period-finding barrier" into a concrete counting question about $g$.

**Conjecture 10.3 (Giuga/Agoh from the read-out).** $N>1$ is prime if and only if $F(N,k)\equiv -1\pmod N$ for some — equivalently, every — $k$ divisible by $\lambda(N)$.

The motivation is Theorem 6.2: when $\lambda(N)\mid k$ the Giuga sum is $\sum_{r\mid N}N/r$, so the criterion becomes exactly Giuga's condition, which is known to force strong constraints on any composite counterexample (each prime factor $r$ would have to satisfy $r \mid N/r - 1$, i.e. $N$ would be a Giuga number as well as a Carmichael number).

**Further directions.** (a) Extend the product formula beyond squarefree $N$: for $p^2\mid N$ the uniform-covering lemma still applies but the block sum modulo $p^2$ has a different dichotomy, governed by $\varphi(p^2)=p(p-1)$. (b) Study the read-out's *statistics*: for random semiprimes, how long is the uninformative prefix and how is the multiset of values distributed over one period? (c) Replace the power sum by weighted sums $\sum_a \chi(a)a^k$ for a Dirichlet character $\chi$; the same covering argument should produce a character-twisted read-out with a richer filter. (d) Quantify the trade-off in Theorem 5.3: over random bases $a$, what fraction fail Pollard's step at exponent $p-1$, and does the aggregation performed by the power sum have a partial, cheaper analogue that sums over a small subset of bases?

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Complete power sum | $\sum_{x\in\mathbb F_p}x^k = -1$ if $(p-1)\mid k$, else $0$ ($k>0$) |
| Reduction mod $p$ | $F(pq,k)\equiv -q$ or $0 \pmod p$ according to $(p-1)\mid k$ |
| Divisibility criterion | For $p\nmid q$, $k>0$: $p\mid F(pq,k)\iff (p-1)\nmid k$ |
| Semiprime gcd formula | $\gcd(F(pq,k),pq)=[\,(p-1)\mid k\,?\,1:p\,]\cdot[\,(q-1)\mid k\,?\,1:q\,]$ |
| Factor reveal | $(q-1)\nmid(p-1)\Rightarrow \gcd(F(pq,p-1),pq)=q$ |
| Product formula | $\gcd(F(N,k),N)=\prod\{r \text{ prime}: r\mid N,\ (r-1)\nmid k\}$ for squarefree $N$ |
| Trivial locus | $\gcd(F(N,k),N)=1\iff \lambda(N)\mid k$ |
| First hit | uninformative for $0<k<\min(p-1,q-1)$; informative at $k=\min(p-1,q-1)$ |
| Robustness | Pollard $p-1$ has a bad base for every even $M$; the power sum has no base |
| Giuga closed form | $F(N,k)\equiv-\sum_{(r-1)\mid k}N/r \pmod N$ |
| Korselt periodicity | $F(N,k+\lambda(N))\equiv F(N,k)\pmod N$ |
| Minimal period | any period of $g_N$ is a multiple of $\lambda(N)$ |
| Lattice law | $g_N(\gcd(k,k'))=\operatorname{lcm}(g_N(k),g_N(k'))$ |
| Recovery identity | $p+q+\lambda(N)\gcd(p-1,q-1)=N+1$; the naive $p+q=N-\lambda+1$ always overshoots |

---

## References

- P. Erdős and others on Giuga's conjecture and Carmichael numbers (classical literature).
- J. M. Pollard, *Theorems on factorization and primality testing*, Mathematical Proceedings of the Cambridge Philosophical Society (1974).
- P. W. Shor, *Polynomial-time algorithms for prime factorization and discrete logarithms on a quantum computer*, SIAM Journal on Computing (1997).
- A. Korselt's criterion for Carmichael numbers (classical).
