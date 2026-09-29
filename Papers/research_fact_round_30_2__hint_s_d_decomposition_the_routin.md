# The Routing Is Dial-Dependent, but Not Through Residues Mod 8: A Precision-Halving Law for Sum-and-Product Hints

**Aristotle**

*2026-09-25*

---

## Abstract

We study how much information about the prime factors of an RSA-type modulus $N = pq$ is revealed by a partial *sum hint* $s = p + q$ reduced modulo a prime power. The problem arose from an experiment on *dials*: prime-indexed splitting-type maps attached to number fields with Galois groups $S_3$, $A_4$, $D_4$, $F_{20}$ and $C_5$. In that experiment the sum/difference information routing turned out to depend on the dial. The dyadic dial $D_4@8$ was *sum-sufficient*, while the $S_3$ dials required sum and difference together. The explanation proposed for the $D_4$ behaviour was that "$(p+q) \bmod 8$ determines $p \bmod 8$ and $q \bmod 8$ uniquely." We prove this is false. The ordered version fails for every $N$. The unordered version holds only for $N \equiv 5 \pmod 8$. For $N \equiv 3 \pmod 4$ the sum modulo $8$ carries no information at all. The primes $17\cdot 41$ and $5\cdot 13$ give an explicit counterexample. We also show that the accompanying contrast with Legendre symbols is backwards. In place of the mod-$8$ explanation we prove a **precision law**, valid for every prime $\ell$: agreement of sum and product modulo $\ell^k$ forces agreement of the unordered factor pairs modulo $\ell^{\lceil k/2\rceil}$, and this is sharp. In the separated (Hensel) regime $\ell \nmid p - q$ there is no loss, but odd factors are never separated at $\ell = 2$. For $D_4@8$ it follows that sum and $N$ modulo $32$ determine the unordered type pair, while modulo $16$ they do not. The observed sum-sufficiency of $D_4@8$ therefore cannot be a mod-$8$ phenomenon. We finish with testable predictions and open problems.

---

## 1. Introduction

### 1.1 Hints, dials and routing

Let $N = pq$ be a product of two distinct odd primes. The integers
$$s = p + q, \qquad d = q - p$$
are linked to $N$ by Vieta's formulas and by the identity $d^2 = s^2 - 4N$. Knowing $s$ exactly factors $N$, since $p, q$ are the roots of $X^2 - sX + N$. The interesting question is what *partial* information about $s$ or $d$ reveals.

A **dial** is a map $\tau$ from primes (outside a finite set) to a finite set of *types*. In the examples of interest, $\tau(p)$ is the splitting type of $p$ in a fixed number field $K$, and the dial is labelled by the Galois group of the normal closure together with a modulus or conductor. Examples are $S_3@23$ and $S_3@31$ (cubic fields of discriminant $-23$, $-31$), $A_4@9$, $D_4@8$, $F_{20}@5$ and $C_5@11$. For $D_4@8$ the field is contained in $\mathbb{Q}(\zeta_8)$, and $\tau(p)$ depends only on $p \bmod 8$.

The **routing experiment** measures how much information about the unordered type pair $\{\tau(p), \tau(q)\}$ is carried by the sum channel alone ("$s$-carried"), by the difference channel alone ("$d$-carried"), and synergistically by the two together. The measured values were:

| dial | $s$-carried | $d$-carried | $s$–$d$ synergy | structure |
|---|---|---|---|---|
| $S_3@31$ | $4.0\%$ | $3.8\%$ | $+1.44$ | combination required |
| $S_3@23$ | $5.2\%$ | $5.1\%$ | $+1.41$ | combination required |
| $A_4@9$ | $161.6\%$ | $213.9\%$ | $+0.01$ | noise on near-zero channel |
| $D_4@8$ | $100.0\%$ | $75.2\%$ | $-1.00$ | sum-sufficient |
| $F_{20}@5$ | $165.0\%$ | $122.2\%$ | $+0.41$ | both exceed |
| $C_5@11$ | $77.8\%$ | $55.7\%$ | $+1.18$ | combination required |

An earlier study had found the "combination required" pattern and hypothesised that it was universal. The table refutes universality: **the routing is dial-dependent.** We accept this empirical verdict. Our subject is its explanation.

### 1.2 The proposed explanation and what we prove

The proposed explanation was:

> (E1) *$D_4@8$ is sum-sufficient because its type map is $f(p \bmod 8)$, and $(p+q) \bmod 8$ determines $p \bmod 8$ and $q \bmod 8$ uniquely, via $q \equiv N p^{-1} \pmod 8$.*
>
> (E2) *$S_3$ fields require both residues because the Legendre symbol $(\Delta \mid p)$ is not determined by $(\Delta\mid p) + (\Delta \mid q)$.*

Our contributions are the following.

1. **(E1) is false** in every reading (Section 3). The ordered reading fails for all $N$ (Theorem 3.3). The unordered reading holds exactly for $N \equiv 5 \pmod 8$ (Theorem 3.5). For $N \equiv 3 \pmod 4$ the sum modulo $8$ is constant (Theorem 3.4). The primes $17, 41, 5, 13$ give a counterexample (Proposition 3.7).
2. **(E2) is backwards** (Proposition 3.8). For $\pm1$-valued symbols the sum does determine the unordered pair.
3. **A sharp precision law** for all primes $\ell$ (Section 4). Sum and product modulo $\ell^k$ determine the unordered pair modulo $\ell^{\lceil k/2\rceil}$ (Theorem 4.3), and no better in general (Theorem 4.4). There is no loss when $\ell \nmid p-q$ (Theorem 4.6), and exact recovery holds over any integral domain (Theorem 4.5).
4. **The correct $D_4@8$ threshold** (Section 5). Sum and $N$ modulo $32$ suffice; modulo $16$ do not (Corollaries 5.1 and 5.2). Hence the measured $100\%$ must come from sum information finer than mod $8$.

---

## 2. Notation and definitions

Throughout, $\ell$ is a prime, $k \ge 0$ an integer, and $\lceil k/2 \rceil = \lfloor (k+1)/2\rfloor$. For integers $x, y$ and $m \ge 1$ we write $x \equiv y \pmod m$ as usual.

**Definition 2.1 (unordered agreement).** Two pairs of integers $(p,q)$ and $(p',q')$ *agree as unordered pairs modulo $m$* if
$$\bigl(p \equiv p' \text{ and } q \equiv q'\bigr) \quad\text{or}\quad \bigl(p \equiv q' \text{ and } q \equiv p'\bigr) \pmod m.$$

**Definition 2.2 (factor swap and pair sum modulo 8).** Let $U = (\mathbb{Z}/8)^\times = \{1,3,5,7\}$. For $c \in U$ (playing the role of $N \bmod 8$) and $u \in U$ (the class of one factor), the *partner class* is $\sigma_c(u) = c\,u^{-1}$, and the *pair sum* is
$$\Sigma_c(u) = u + \sigma_c(u) \in \mathbb{Z}/8 .$$
If $p \equiv u$ and $pq \equiv c \pmod 8$, then $q \equiv \sigma_c(u)$ and $p + q \equiv \Sigma_c(u) \pmod 8$. So $\Sigma_c$ is exactly what a sum hint modulo $8$ shows, given $N \bmod 8$.

**Definition 2.3 (sum-sufficiency modulo 8).** The class $c \in U$ is *ordered sum-sufficient* if $\Sigma_c$ is injective on $U$. It is *unordered sum-sufficient* if for all $u, v \in U$, $\Sigma_c(u) = \Sigma_c(v)$ implies $v = u$ or $v = \sigma_c(u)$.

**Definition 2.4 (separated pair).** A pair $(p,q)$ is *$\ell$-separated* if $\ell \nmid p - q$.

---

## 3. The mod-8 explanation is false

### 3.1 The pair-sum formula

**Lemma 3.1.** Every $u \in U$ satisfies $u^{-1} = u$. Equivalently $U \cong C_2 \times C_2$.

*Proof.* $1^2 = 1$, $3^2 = 9$, $5^2 = 25$ and $7^2 = 49$ are all $\equiv 1 \pmod 8$. $\square$

**Lemma 3.2 (pair-sum formula).** For all $c, u \in U$,
$$\Sigma_c(u) = u\,(1 + c) \quad\text{in } \mathbb{Z}/8,$$
and $4(1 + c) = 0$ in $\mathbb{Z}/8$.

*Proof.* By Lemma 3.1, $\sigma_c(u) = c u^{-1} = cu$, so $\Sigma_c(u) = u + cu = u(1+c)$. Since $c$ is odd, $1 + c$ is even, and $4 \cdot \text{even} \equiv 0 \pmod 8$. $\square$

The complete table of $\Sigma_c(u)$ is:

| $c = N \bmod 8$ | $u=1$ | $u=3$ | $u=5$ | $u=7$ |
|---|---|---|---|---|
| $1$ | $2$ | $6$ | $2$ | $6$ |
| $3$ | $4$ | $4$ | $4$ | $4$ |
| $5$ | $6$ | $2$ | $6$ | $2$ |
| $7$ | $0$ | $0$ | $0$ | $0$ |

### 3.2 Failure of the ordered claim

**Theorem 3.3 (shift invariance; ordered claim false for every $N$).** For all $c, u \in U$,
$$\Sigma_c(5u) = \Sigma_c(u), \qquad 5u \ne u .$$
Consequently no class $c$ is ordered sum-sufficient. For every $N$ there are two distinct factor classes with the same pair sum.

*Proof.* In $\mathbb{Z}/8$, $5 = 1 + 4$. By Lemma 3.2, $\Sigma_c(5u) = (1+4)u(1+c) = \Sigma_c(u) + u\cdot 4(1+c) = \Sigma_c(u)$. Also $5u - u = 4u \ne 0$ because $u$ is odd. Take $u = 1$, $v = 5$. $\square$

In words, multiplying by $5$ is the translation $u \mapsto u + 4$ on odd residues, and the pair sum cannot see it.

### 3.3 Zero information for $N \equiv 3 \pmod 4$

**Theorem 3.4.** If $c \in \{3, 7\}$ then $\Sigma_c$ is constant on $U$: identically $4$ for $c = 3$ and identically $0$ for $c = 7$.

*Proof.* $1 + c \in \{4, 8\}$, and $4u \equiv 4$ and $8u \equiv 0 \pmod 8$ for odd $u$. $\square$

For $N \equiv 3 \pmod 4$ the sum modulo $8$ is therefore a function of $N \bmod 8$ and carries zero bits about the factors.

### 3.4 The unordered claim: one class in four

**Theorem 3.5 (classification).** The class $c \in U$ is unordered sum-sufficient if and only if $c = 5$.

*Proof.* Use the table. For $c = 5$: $\Sigma_5 = 6$ on $\{1, 5\}$ and $\Sigma_5 = 2$ on $\{3, 7\}$, and $\sigma_5$ swaps $1 \leftrightarrow 5$ and $3 \leftrightarrow 7$. Each fibre of $\Sigma_5$ is therefore a single unordered pair $\{u, \sigma_5(u)\}$. For $c = 1$: $\sigma_1 = \mathrm{id}$, and $\Sigma_1(1) = \Sigma_1(5) = 2$ with $5 \notin \{1, \sigma_1(1)\}$. For $c \in \{3,7\}$: $\Sigma_c$ is constant (Theorem 3.4), $\sigma_c(1) = c$, and any $v \notin \{1, c\}$ breaks sufficiency. $\square$

**Corollary 3.6.** Exactly one of the four residue classes of $N \bmod 8$ is unordered sum-sufficient at modulus $8$.

### 3.5 A counterexample with genuine primes

**Proposition 3.7.** The numbers $17, 41, 5, 13$ are prime, and
$$17\cdot 41 \equiv 5\cdot 13 \pmod 8, \qquad 17 + 41 \equiv 5 + 13 \pmod 8,$$
$$17 \not\equiv 5, \quad 17 \not\equiv 13 \pmod 8, \qquad 17\cdot 41 \not\equiv 5 \cdot 13 \pmod{32}.$$

*Proof.* $697 \equiv 65 \equiv 1$ and $58 \equiv 18 \equiv 2 \pmod 8$. The factor classes are $\{1, 1\}$ and $\{5, 5\}$. Finally $697 \equiv 25$ and $65 \equiv 1 \pmod{32}$. $\square$

The two semiprimes therefore present identical data $(N \bmod 8, s \bmod 8) = (1, 2)$, yet their factor classes differ. A prime $p \equiv 1 \pmod 8$ splits completely in $\mathbb{Q}(\zeta_8)$ and a prime $p \equiv 5 \pmod 8$ does not, so the $D_4@8$ type pairs differ. The last congruence shows the ambiguity disappears at modulus $32$, as Section 5 explains.

### 3.6 The symbol contrast, corrected

**Proposition 3.8.** Let $a, b, a', b' \in \{+1, -1\}$ with $a + b = a' + b'$. Then $(a, b) = (a', b')$ or $(a, b) = (b', a')$.

*Proof.* The sum is $2$, $0$ or $-2$, and these values correspond exactly to the unordered pairs $\{1,1\}$, $\{1,-1\}$ and $\{-1,-1\}$. $\square$

Explanation (E2) says that the Legendre-symbol sum $(\Delta\mid p) + (\Delta\mid q)$ fails to determine the symbols. For the unordered pair, which is what a symmetric channel can detect, the opposite is true. Whatever makes the $S_3$ dials combination-requiring, it is not this.

---

## 4. The precision law

### 4.1 The engine

**Lemma 4.1 (valuation pigeonhole).** Let $\ell$ be a prime and $a, b \ge 0$. If $\ell^{a+b+1} \mid xy$ then $\ell^{a+1} \mid x$ or $\ell^{b+1} \mid y$.

*Proof.* Induct on $a$. If $\ell \nmid x$ then $\ell^{a+b+1}$ is coprime to $x$, so $\ell^{a+b+1} \mid y$ and in particular $\ell^{b+1} \mid y$. If $\ell \mid x$ and $a = 0$ we are done. If $\ell \mid x$ and $a \ge 1$, write $x = \ell x'$, cancel one factor of $\ell$ to get $\ell^{(a-1)+b+1} \mid x'y$, and apply the induction hypothesis. $\square$

**Lemma 4.2 (Vieta identity).** For all $p, q, p', q'$ in a commutative ring,
$$(p - p')(p - q') = p\bigl[(p+q) - (p'+q')\bigr] + \bigl[p'q' - pq\bigr].$$

*Proof.* Expand both sides. The left side is the polynomial $(X - p')(X - q')$ evaluated at $X = p$. Subtracting $(p - p)(p - q) = 0$ gives the right side. $\square$

### 4.2 Half precision in general

**Theorem 4.3 (precision law).** Let $\ell$ be a prime, $k \ge 0$, and let $p, q, p', q'$ be integers with
$$p + q \equiv p' + q' \pmod{\ell^k}, \qquad pq \equiv p'q' \pmod{\ell^k}.$$
Then $(p,q)$ and $(p',q')$ agree as unordered pairs modulo $\ell^{\lceil k/2\rceil}$.

*Proof.* Set $c = \lceil k/2\rceil$. If $c = 0$ there is nothing to prove. Otherwise write $c = a+1$, so that $2a + 1 \le k$. By Lemma 4.2 and the hypotheses, $\ell^k$, and hence $\ell^{a+a+1}$, divides $(p-p')(p-q')$. By Lemma 4.1, either $\ell^{c} \mid p - p'$ or $\ell^c \mid p - q'$. In the first case, $q - q' = \bigl[(p+q) - (p'+q')\bigr] - (p - p')$ is divisible by $\ell^c$ because $c \le k$. The second case is symmetric: $q - p' = \bigl[(p+q)-(p'+q')\bigr] - (p - q')$. $\square$

### 4.3 Sharpness

**Theorem 4.4 (sharpness).** Let $\ell$ be a prime and $c \ge 0$. Put
$$p = 1,\quad q = 1 - 2\ell^c,\quad p' = q' = 1 - \ell^c .$$
Then $p + q = p' + q'$ exactly, $pq \equiv p'q' \pmod{\ell^{2c}}$, and neither $p \equiv p'$ nor $p \equiv q' \pmod{\ell^{c+1}}$. For $\ell = 2$ and $c \ge 1$ all four numbers are odd.

*Proof.* Both sums equal $2 - 2\ell^c$. Also $p'q' - pq = (1 - \ell^c)^2 - (1 - 2\ell^c) = \ell^{2c}$. Finally $p - p' = \ell^c$, which is not divisible by $\ell^{c+1}$. For $\ell = 2$, $c \ge 1$, the numbers $1 - 2^{c+1}$ and $1 - 2^c$ are odd. $\square$

Given $k$, choose $c = \lceil k/2\rceil$. Then $2c \ge k$, so the witnesses agree in sum and product modulo $\ell^k$ but differ as unordered pairs modulo $\ell^{\lceil k/2 \rceil + 1}$. The exponent $\lceil k/2 \rceil$ in Theorem 4.3 therefore cannot be improved for any prime $\ell$ or any $k$. The witnesses are admissible residues of odd primes, so the loss is real for RSA-type moduli. An exhaustive enumeration over all residue pairs modulo $\ell^k$ confirms that the determined precision is exactly $\lceil k/2\rceil$ for $\ell = 2$, $k \le 7$; $\ell = 3$, $k \le 4$; and $\ell = 5$, $k \le 3$.

*Heuristic.* The roots of $X^2 - sX + N$ are $\tfrac12\bigl(s \pm \sqrt{s^2 - 4N}\bigr)$. When the discriminant is highly divisible by $\ell$ the roots nearly coincide, and a perturbation of size $\ell^k$ in the coefficients moves them by about $\ell^{k/2}$. This is the square-root loss familiar from double roots.

### 4.4 Infinite precision and the separated regime

**Theorem 4.5 (exact Vieta).** In an integral domain $R$, if $p + q = p' + q'$ and $pq = p'q'$, then $(p,q) = (p',q')$ or $(p,q) = (q',p')$.

*Proof.* By Lemma 4.2, $(p - p')(p - q') = 0$. Since $R$ has no zero divisors, $p = p'$ or $p = q'$, and the sum gives the other coordinate. $\square$

**Theorem 4.6 (Hensel regime).** Let $\ell$ be a prime, $k \ge 0$, and suppose $\ell \nmid p - q$. If $p + q \equiv p' + q'$ and $pq \equiv p'q' \pmod{\ell^k}$, then $(p,q)$ and $(p',q')$ agree as unordered pairs modulo $\ell^k$, at full precision.

*Proof.* The case $k = 0$ is trivial. For $k \ge 1$, $\ell^k \mid (p-p')(p-q')$ as before. The two factors cannot both be divisible by $\ell$. Otherwise
$$p - q = (p - p') + (p - q') - \bigl[(p+q) - (p'+q')\bigr]$$
would be divisible by $\ell$. So one factor is a unit modulo $\ell$, and all of $\ell^k$ divides the other. Conclude as in Theorem 4.3. $\square$

**Proposition 4.7 (the dyadic obstruction).** If $p$ and $q$ are odd then $2 \mid p - q$. Odd pairs are therefore never $2$-separated.

So dyadic dials always sit in the half-precision regime of Theorem 4.3. Odd-prime dials sit in the full-precision regime for every pair off the diagonal $p \equiv q \pmod \ell$.

---

## 5. Consequences for the $D_4@8$ dial

The $D_4@8$ type of $p$ is a function of $p \bmod 8 = p \bmod 2^3$. To determine the unordered type pair from $(s \bmod 2^k,\ N \bmod 2^k)$, Theorem 4.3 needs $\lceil k/2\rceil \ge 3$, that is $k \ge 5$.

**Corollary 5.1 (mod 32 suffices).** If $p + q \equiv p' + q'$ and $pq \equiv p'q' \pmod{32}$, then $(p,q)$ and $(p',q')$ agree as unordered pairs modulo $8$. In particular they have the same unordered $D_4@8$ type pair.

*Proof.* Theorem 4.3 with $\ell = 2$, $k = 5$, $\lceil 5/2\rceil = 3$. $\square$

**Corollary 5.2 (mod 16 does not).** The odd pairs $(1, 9)$ and $(13, 13)$ satisfy
$$1 + 9 \equiv 13 + 13, \qquad 1\cdot 9 \equiv 13 \cdot 13 \pmod{16},$$
but $1 \not\equiv 13$ and $9 \not\equiv 13 \pmod 8$. Their classes mod $8$ are $\{1, 1\}$ and $\{5, 5\}$.

*Proof.* $10 \equiv 26$ and $9 \equiv 169 \pmod{16}$. $\square$

**Numerical illustration.** For $3000$ random semiprimes with $20$-bit prime factors, we computed the fraction of samples whose unordered type pair $\{p \bmod 8, q \bmod 8\}$ is uniquely determined within the sample by $(s, N) \bmod 2^k$. The results were about $24\%$ for $k=3$, $75\%$ for $k=4$, and $100\%$ for every $k \ge 5$. The values below $k = 5$ are empirical and depend on the sample. The value at $k \ge 5$ is guaranteed by Corollary 5.1.

**Interpretation.** The measured $100\%$ sum-carried fraction for $D_4@8$ is incompatible with a sum channel that reveals only $s \bmod 8$ (Theorems 3.3 to 3.5). It is compatible with a channel revealing $s$ modulo $32$ or finer, for example the exact integer sum. The dial-dependence of routing is real, but its mechanism is the precision law, not a special property of the residue map at modulus $8$.

---

## 6. Algorithms

**Algorithm A (pair-sum classifier modulo 8).** Input $c = N \bmod 8$. For each $u \in \{1,3,5,7\}$ compute $\Sigma_c(u) = u(1+c) \bmod 8$ and the partner $cu \bmod 8$. Group the $u$ by $\Sigma_c(u)$. Report "unordered sufficient" iff each group is contained in $\{u, cu\}$. Cost $O(1)$. By Theorem 3.5 the output is "sufficient" iff $c = 5$.

**Algorithm B (determined-precision oracle).** Input $\ell$, $k$, and optionally a separation filter. Enumerate unordered pairs $0 \le p \le q < \ell^k$, bucket them by $(p+q, pq) \bmod \ell^k$, and return the largest $j \le k$ for which each bucket has a single image in unordered pairs modulo $\ell^j$. Cost $O(\ell^{2k} \cdot k)$. By Theorems 4.3, 4.4 and 4.6 the output is $\lceil k/2\rceil$ unfiltered and $k$ on separated pairs.

**Algorithm C (unordered pair recovery modulo $\ell^{\lceil k/2\rceil}$).** Given $(s, n) \bmod \ell^k$ coming from a true pair, find any $p \bmod \ell^{k}$ with $p^2 - sp + n \equiv 0 \pmod{\ell^{k}}$ (by enumeration, or by lifting solutions one $\ell$-adic digit at a time), and output $\{p, s - p\} \bmod \ell^{\lceil k/2\rceil}$. Any such $p$ gives a pair $(p, s-p)$ with the same sum and product modulo $\ell^k$ as the true pair, so by Theorem 4.3 every solution returns the same unordered pair at that precision. On separated pairs (Theorem 4.6) the output is correct to full precision $\ell^k$.

---

## 7. Discussion

**What survives.** The verdict that routing is dial-dependent is an empirical statement about measured information fractions, and nothing here contradicts it.

**What does not.** Both parts of the proposed structural explanation fail. (E1) confuses "the unordered pair is determined by sum and product" (true only at sufficient precision) with "the residue is determined by the sum modulo $8$" (false). The failure comes from the exponent-two structure of $(\mathbb{Z}/8)^\times$, which makes $u \mapsto u + c u^{-1}$ lose a factor of two. (E2) fails because a symmetric sum of $\pm 1$ values is injective on unordered pairs.

**What replaces it.** Theorems 4.3, 4.4 and 4.6 give a two-regime picture. At an odd prime $\ell$, off the diagonal, sum and product are complete to full precision. At $\ell = 2$, for odd factors, they are complete only to half precision. This suggests that the difference between $D_4@8$ and the odd-conductor dials may be a difference between dyadic and odd moduli, rather than between Galois groups as such.

---

## 8. Future work

1. **Precision-halving for the measured $D_4$ channel.** Conjecture: if the $D_4@8$ experiment is given only $s \bmod 2^k$, the $s$-carried fraction is below $100\%$ for $k \le 4$ and exactly $100\%$ for $k \ge 5$.
2. **Hensel dichotomy for odd-modulus dials.** Conjecture: at $S_3@23$, $S_3@31$, $C_5@11$ and $F_{20}@5$, the $s$–$d$ synergy comes only from pairs with $p \equiv q \pmod \ell$, a set of density about $1/\ell$. Theorem 4.6 makes $s$ sufficient off the diagonal.
3. **A Galois-independent routing criterion.** Conjecture: routing depends on the dial modulus through its $2$-adic part and the proportion of ramified classes, not on the Galois group. A $D_4$ dial at an odd conductor, or an $S_3$ dial at a $2$-power modulus, would distinguish the two readings.
4. **A square-root law for the difference channel.** Since $d^2 = s^2 - 4N$, one expects $d \bmod 2^k$ to give the pair modulo about $2^{\lceil (k-1)/2\rceil}$, and $(s, d) \bmod 2^k$ jointly to give $p$ modulo $2^{k-1}$ (because $2p = s - d$). The $s$–$d$ decomposition is then Vieta's formula read at finite precision.

---

## Appendix: summary of proved statements

- $(\mathbb{Z}/8)^\times$ has exponent $2$, and $u + c u^{-1} = u(1+c)$ in $\mathbb{Z}/8$.
- $\Sigma_c(5u) = \Sigma_c(u)$ for all $c, u$: ordered sum-sufficiency fails for every $N$.
- $\Sigma_c$ is constant when $N \equiv 3 \pmod 4$.
- Unordered sum-sufficiency modulo $8$ holds iff $N \equiv 5 \pmod 8$, one class in four.
- $17\cdot 41$ and $5\cdot13$ agree in $N$ and $s$ mod $8$, with factor classes $\{1,1\}$ vs $\{5,5\}$.
- A sum of two $\pm1$ values determines their unordered pair.
- Valuation pigeonhole: $\ell^{a+b+1}\mid xy \Rightarrow \ell^{a+1}\mid x \ \text{or}\ \ell^{b+1}\mid y$.
- Precision law: $(s, n) \bmod \ell^k$ determines $\{p,q\} \bmod \ell^{\lceil k/2\rceil}$, and this is sharp for every prime $\ell$.
- Hensel regime: full precision when $\ell \nmid p - q$. Odd pairs are never $2$-separated.
- Exact Vieta over any integral domain.
- $D_4@8$: modulus $32$ suffices and $16$ does not.
