# The Sieve's Advantage Is the Survivor Filter: Exact Thresholds, Hensel Lines, and the Quadratic-Residue Restriction of the Relation Pool in a Toy Quadratic Sieve

**Author:** Aristotle

---

## Abstract

We measure and analyze the relation-collection phase of a toy quadratic sieve (QS) for semiprimes $N$ up to $2^{32}$. We ask two questions. (H1) Is the sieve's advantage over naive trial division a constant factor coming from filtering survivors, or does it grow with scale? (H2) Is the relation yield predicted by the "random integer" model $0.90\,\rho(u)$, where $\rho$ is Dickman's function? H1 is confirmed. The measured advantage lies between $13.68\times$ and $20.51\times$ across six settings, and its ratio to the factor-base size is flat at $0.12$–$0.22$. H2 is refuted: the model overpredicts yield by about $1.55\times$ at median $u \approx 3$.

We support both findings with exact theorems. **(i)** The log-sieve threshold accepts a value $v$ if and only if $v$ is smooth over the factor base with every exponent at most the sieve height $K$. In particular, a sieve that uses first powers only accepts exactly the squarefree smooth values, and a sieve with $K \ge \log_2 v$ agrees exactly with trial division. **(ii)** For an odd prime $p \nmid N$, the congruence $x^2 \equiv N \pmod{p^k}$ has exactly two solutions for every $k \ge 1$ when $(N\mid p) = +1$ and none when $(N\mid p) = -1$. For odd $N$ the $2$-adic height is capped by $N \bmod 8$. **(iii)** The total sieve work over a window of $M$ values is at most $\sum_{p}\sum_{k\le K} 2(M/p^k+1)$. **(iv)** Restricting to quadratic-residue primes, read as an effective bound $B/2$, multiplies $u$ exactly by $\ln B/(\ln B - \ln 2) > 1$. This explains the direction of the H2 deviation, with a cross-setting correlation of $0.72$. **(v)** We prove the chain that turns relations into a factor, including the Chinese Remainder "coin flip": a unit square modulo $pq$ has exactly four square roots, exactly two of which are non-trivial. We exhibit a complete certificate factoring $N = 103\,764\,863 = 9127 \times 11369$ from four relations, each of which has a repeated prime factor and would therefore be lost by a first-power sieve.

---

## 1. Introduction

The quadratic sieve factors an odd composite $N$ in two phases. In the *relation-collection* phase it searches for integers $x$ near $\sqrt N$ for which $Q(x) = x^2 - N$ is $B$-smooth, meaning all prime factors are at most $B$. In the *linear-algebra* phase it finds a subset of relations whose product is a perfect square and extracts a factor of $N$ from the resulting congruence of squares.

Two standard claims about the first phase are usually stated without much measurement:

1. *Sieving is much faster than trial division.* Each prime $p$ divides $Q(x)$ along a few arithmetic progressions in $x$, so one can add $\log p$ along those progressions and avoid testing each $Q(x)$ separately.
2. *The yield follows Dickman's function.* The probability that $Q(x)$ is $B$-smooth is roughly $\rho(u)$ with $u = \ln Q(x)/\ln B$, as for a random integer of the same size.

An earlier round of this project fitted the model $0.90\,\rho(u)$ in the range $u \in [2,3]$, values up to $2^{23}$, and left open how large the sieve's algorithmic advantage actually is. Here we close that question and test the yield model at larger scale. We find:

* **H1 (confirmed).** The advantage $A_{\text{total}}$ of the sieve over trial division is the constant survivor-filtering factor: $13.68$–$20.51\times$ across six settings, with $A/\pi_{\text{FB}}$ flat at $0.12$–$0.22$ and no growth with scale. Here $\pi_{\text{FB}}$ is the factor-base size. Measured per value, roughly $100$ divisions are replaced by roughly $2$ log additions, plus trial division of survivors only.
* **H2 (refuted, refining the earlier model).** The model $0.90\,\rho(u)$ overpredicts yield by about $1.55\times$ at $u_{\text{med}} \approx 3$, and none of the six settings falls in the predicted band. The reason is structural. A prime $p$ divides $x^2 - N$ only if $(N \mid p) = +1$, so smoothness of $Q(x)$ is decided over the *quadratic-residue-restricted* prime pool. Read as an effective bound, this raises $u$ by the factor $\ln B/(\ln B - \ln 2)$. That predicts yield ratios $0.44$–$0.52$. We observed $0.54$–$0.76$, with cross-setting correlation $0.72$.

The paper explains both findings with exact theorems and also records a methodological lesson. Two real implementation bugs, the omission of prime-power sieve lines and a per-root modular-inverse error, were caught *only* by an independent brute-force recount. The sieve's internal consistency gate predicted the yield using the same omission, so it could not detect it.

### 1.1 Notation

$N$ is an odd integer greater than $1$ that is not a perfect square. $Q(x) = x^2 - N$. For a prime $p$ and a nonzero integer $v$, $v_p(v)$ is the exponent of $p$ in $v$. $(N \mid p)$ is the Legendre symbol. $\pi(B)$ is the number of primes up to $B$. A positive integer $v$ is *$S$-smooth*, for a set $S$ of primes, if every prime divisor of $v$ lies in $S$. It is *$B$-smooth* if it is $S$-smooth for $S = \{p \le B\}$. Dickman's function $\rho$ is the continuous solution of $\rho(u) = 1$ for $0 \le u \le 1$ and $u\rho'(u) = -\rho(u-1)$ for $u > 1$.

---

## 2. The log sieve and its exact acceptance criterion

### 2.1 Definitions

Let $S$ be a finite set of primes and $K \ge 1$ an integer, the *sieve height*. A sieve of height $K$ marks, for every $p \in S$ and every $1 \le k \le K$, all $x$ with $p^k \mid Q(x)$, and adds $\log p$ at each mark.

**Definition 2.1 (hits, seen part, accumulator).** For a positive integer $v$ define
$$h_K(v,p) = \#\{\,1 \le k \le K : p^k \mid v\,\},\qquad P_{S,K}(v) = \prod_{p\in S} p^{\,h_K(v,p)},\qquad L_{S,K}(v) = \sum_{p\in S} h_K(v,p)\,\log p.$$
The value $v$ *survives* the sieve if $L_{S,K}(v) = \log v$.

In practice the comparison is made with a tolerance. The exact equality isolates the combinatorial content of the test.

### 2.2 Results

**Lemma 2.2 (hits are truncated valuations).** For a prime $p$ and $v \neq 0$, $h_K(v,p) = \min(v_p(v), K)$.

*Proof.* We have $p^k \mid v$ if and only if $k \le v_p(v)$. So the counted set is $\{1,\dots,\min(v_p(v),K)\}$. $\square$

**Lemma 2.3 (the accumulator is a logarithm of a divisor).** $L_{S,K}(v) = \log P_{S,K}(v)$, and $P_{S,K}(v) \mid v$. Consequently $L_{S,K}(v) \le \log v$.

*Proof.* The first identity is $\log$ of a product. By Lemma 2.2 the exponent of $p$ in $P_{S,K}(v)$ is $\min(v_p(v),K) \le v_p(v)$ for $p \in S$ and $0$ otherwise, so $P_{S,K}(v)$ divides $v$. $\square$

**Theorem 2.4 (exact acceptance criterion).** For $v \ge 1$,
$$L_{S,K}(v) = \log v \iff v \text{ is } S\text{-smooth and } v_p(v) \le K \text{ for every prime } p.$$

*Proof.* Since $\log$ is injective on positive reals, survival is equivalent to $P_{S,K}(v) = v$. Since $P_{S,K}(v) \mid v$, this means equality of valuations at every prime: $\min(v_p(v),K) = v_p(v)$ for $p \in S$ and $v_p(v) = 0$ for $p \notin S$. $\square$

**Corollary 2.5 (the first-power sieve).** With $K = 1$, $v$ survives if and only if $v$ is $S$-smooth **and squarefree**. If $v$ is not squarefree then $L_{S,1}(v) < \log v$ strictly.

**Corollary 2.6 (exactness of the full sieve).** Let $S = \{p \le B\}$ and $K \ge \log_2 v$. Then $v$ survives if and only if $v$ is $B$-smooth. In other words, the survivors are exactly the values that trial division by all primes up to $B$ would accept.

*Proof.* For every prime, $v_p(v) \le \log_p v \le \log_2 v \le K$, so the exponent condition of Theorem 2.4 is automatic. $\square$

### 2.3 Interpretation

Corollary 2.6 is what lets us read H1 as a purely algorithmic gain. The full sieve loses no relation and admits no false positive, so any speed-up over trial division is speed-up and not lost yield. Corollary 2.5 identifies the failure mode recorded in our experiment ledger. A sieve marking only the lines modulo $p$ discards every relation with a repeated prime factor. With an exact threshold the loss is precisely the share of non-squarefree values among smooth values. In our six settings that share was between $54\%$ and $91\%$. With a looser practical threshold some of these values survive anyway, which is why the first diagnosis ("prime-power lines restore about $20\%$") depended on the threshold.

---

## 3. Sieve lines modulo prime powers

For the full sieve one needs the residues $x \bmod p^k$ with $p^k \mid Q(x)$. Let $r(p^k)$ denote their number.

### 3.1 Odd primes

**Lemma 3.1 (Hensel step).** Let $p$ be an odd prime, $k \ge 1$, and $x \in \mathbb Z$ with $p^k \mid x^2 - N$ and $p \nmid x$. Then there is $y \equiv x \pmod{p^k}$ with $p^{k+1} \mid y^2 - N$.

*Proof sketch.* Write $x^2 - N = p^k c$ and look for $y = x + t p^k$. Then $y^2 - N = p^k(c + 2xt) + t^2p^{2k}$. Since $2k \ge k+1$, it is enough to choose $t$ with $c + 2xt \equiv 0 \pmod p$. This is possible because $2x$ is invertible modulo $p$, as $p$ is odd and $p \nmid x$. $\square$

If $p \nmid N$, any root of $x^2 \equiv N \pmod{p^k}$ automatically satisfies $p \nmid x$. Induction on $k$ then gives:

**Theorem 3.2 (Hensel lifting).** If $p$ is an odd prime, $p \nmid N$ and $p \mid x_0^2 - N$, then for every $k \ge 1$ there is $y \equiv x_0 \pmod p$ with $p^k \mid y^2 - N$.

**Lemma 3.3 (at most two lines).** If $p$ is odd, $p \nmid N$, and $p^k$ divides both $x^2 - N$ and $y^2 - N$, then $p^k \mid x - y$ or $p^k \mid x + y$.

*Proof.* $p^k \mid (x-y)(x+y)$. If $p$ divided both factors it would divide $2x$, hence $x$, hence $N$. So $p$ is coprime to one factor, and $p^k$ divides the other. $\square$

**Theorem 3.4 (exactly two lines, or none).** Let $p$ be an odd prime with $p \nmid N$ and let $k \ge 1$.
1. If $(N\mid p) = +1$, then $r(p^k) = 2$.
2. If $(N\mid p) = -1$, then $r(p^k) = 0$.

*Proof.* (1) Theorem 3.2 lifts a root $x_0$ to a root $y$ modulo $p^k$. Then $-y$ is also a root, and $y \not\equiv -y$ because $p \nmid 2y$. Lemma 3.3 shows that every root equals $\pm y$. (2) A root modulo $p^k$ reduces to a root modulo $p$, and there is none. $\square$

Theorem 3.4 is the structural fact behind both hypotheses. It gives the multiplicity (exactly two lines at every level), which bounds the work in Section 4. It also gives the support: only primes with $(N\mid p) = +1$ ever divide a value, which drives the yield analysis in Section 5.

### 3.2 The prime 2

Hensel's lemma in the form above fails at $p = 2$, because $2x$ is not a unit. Instead we use the elementary fact that odd squares are $\equiv 1 \pmod 8$.

**Proposition 3.5 (2-adic cap).** Let $N$ be odd.
1. If $4 \mid x^2 - N$ for some $x$, then $N \equiv 1 \pmod 4$.
2. If $8 \mid x^2 - N$ for some $x$, then $N \equiv 1 \pmod 8$.

*Proof.* If $4 \mid x^2 - N$ with $N$ odd, then $x$ is odd, so $x^2 \equiv 1 \pmod 8$ and $N \equiv x^2 \pmod 4$ (respectively $\pmod 8$). $\square$

So for $N \equiv 3 \pmod 4$ the $2$-power lines stop at height $1$, and for $N \equiv 5 \pmod 8$ they stop at height $2$. For our toy modulus $N = 103\,764\,863 \equiv 7 \pmod 8$, no value $x^2 - N$ is divisible by $4$.

---

## 4. The work bound (H1)

### 4.1 Counting hits in a window

**Lemma 4.1 (residue classes in a window).** For $m \ge 1$, any window of $M$ consecutive integers contains at most $\lfloor M/m \rfloor + 1$ integers in any fixed residue class modulo $m$.

*Proof.* Map each such integer $x$ in $[a, a+M)$ to $\lfloor (x-a)/m \rfloor \in \{0, \dots, \lfloor M/m\rfloor\}$. Two members of the same class differ by a nonzero multiple of $m$ and so have different images. $\square$

**Proposition 4.2 (hits per prime power).** For an odd prime $p \nmid N$ and $k \ge 0$, at most $2(\lfloor M/p^k\rfloor + 1)$ of the integers $x$ in a window of length $M$ satisfy $p^k \mid x^2 - N$.

*Proof.* By Lemma 3.3 all such $x$ lie in at most two residue classes modulo $p^k$. Apply Lemma 4.1. $\square$

**Theorem 4.3 (total sieve work).** Let $S$ be a set of odd primes not dividing $N$. The total number of log additions made by a height-$K$ sieve over a window of $M$ consecutive $x$ is
$$\sum_{x}\sum_{p\in S} h_K\bigl(|x^2-N|,\,p\bigr) \;\le\; \sum_{p\in S}\sum_{k=1}^{K} 2\left(\left\lfloor \frac{M}{p^k}\right\rfloor + 1\right).$$

*Proof.* Exchange the order of summation: $\sum_x h_K(\cdot,p) = \sum_{k=1}^K \#\{x : p^k \mid x^2 - N\}$. Then apply Proposition 4.2. $\square$

### 4.2 Interpretation and measurements

Per value, Theorem 4.3 gives about $2\sum_{p\in S}\sum_k p^{-k} \approx 2\sum_{p \in S} 1/(p-1)$ additions. By Mertens' theorem this grows only like $\log\log B$. Trial division costs about $\pi(B)$ divisions per value. The algorithmic advantage is therefore a *survivor filter*: cheap additions everywhere, expensive division only on survivors, which are exactly the smooth values by Corollary 2.6.

**Measurements.** We ran six settings with $N$ up to $2^{32}$. Each run used a fixed seed, and we cross-checked against brute-force trial division on independent subranges.

| quantity | observed |
|---|---|
| total advantage $A_{\text{total}}$ | $13.68\times$ – $20.51\times$ |
| $A/\pi_{\text{FB}}$ | $0.12$ – $0.22$, flat in $N$ |
| per-value cost, trial division | $\approx 100$ divisions |
| per-value cost, sieve | $\approx 2$ log additions + survivors' divisions |
| brute-force subrange agreement | $338/338$ relations exact |
| advantage on subrange vs. full window | $14.07\times$ vs. $15.29\times$ |

The advantage did not grow with scale. Its size is set by the ratio of factor-base size to per-value sieve cost, as Theorem 4.3 predicts.

---

## 5. The relation pool is quadratic-residue restricted (H2)

### 5.1 The support of $Q(x)$

**Proposition 5.1 (support).** If $p$ is an odd prime with $p \nmid N$ and $p \mid x^2 - N$ for some $x$, then $(N\mid p) = +1$.

This is Theorem 3.4(2) with $k = 1$. Hence every $B$-smooth value $Q(x)$ is in fact smooth over the *admissible* set
$$\mathcal P(N,B) = \{2\} \cup \{\,p \le B \text{ odd} : p \mid N \text{ or } (N \mid p) = +1\,\}.$$
By quadratic reciprocity and Dirichlet's theorem, this set contains about half the primes up to $B$. For $N = 103\,764\,863$ and $B = 60$, $\mathcal P(N,B) = \{2,11,17,19,23,31,37,43,47,59\}$, which is $10$ of the $17$ primes up to $60$.

### 5.2 Effective $u$

A random integer near $v$ draws its small prime factors from *all* primes, but $Q(x)$ draws them only from $\mathcal P(N,B)$. A first-order way to quantify the deficit is to treat the restricted pool as though the smoothness bound were halved, $B \mapsto B/2$. This is a heuristic. It ignores the compensating fact that each admissible prime power is hit along *two* lines (Theorem 3.4).

**Proposition 5.2 (effective-$u$ identity).** For real $B > 2$ and $v > 1$,
$$\frac{\ln v}{\ln (B/2)} \;=\; \frac{\ln v}{\ln B}\cdot\frac{\ln B}{\ln B - \ln 2}, \qquad\text{and}\qquad \frac{\ln v}{\ln(B/2)} > \frac{\ln v}{\ln B}.$$

*Proof.* $\ln(B/2) = \ln B - \ln 2$, and $0 < \ln B - \ln 2 < \ln B$ when $B > 2$. $\square$

Write $u = \ln v/\ln B$ and $u_{\text{eff}} = u\,\ln B/(\ln B - \ln 2)$. The QR-restricted model predicts a yield ratio of $\rho(u_{\text{eff}})/\rho(u)$ relative to the random-integer model.

### 5.3 Measurements

| quantity | observed |
|---|---|
| overprediction of $0.90\,\rho(u)$ at $u_{\text{med}} \approx 3$ | $\approx 1.55\times$ |
| settings inside predicted band | $0/6$ |
| QR-restricted predicted yield ratio | $0.44$ – $0.52$ |
| observed yield ratio | $0.54$ – $0.76$ |
| cross-setting correlation (predicted vs. observed) | $0.72$ |

The QR-restriction reading gets the sign of the deviation right and tracks its variation across settings. It overcorrects the size, which is consistent with leaving out the doubled hit rate. The earlier finding (gap factor $0.90$ for $u \in [2,3]$, $v \le 2^{23}$) still holds in its own range. Beyond it, the right reference population is QR-restricted integers, not all integers.

### 5.4 A methodological note on circular gates

Our experiment included a consistency gate that compared the sieve's output with a *predicted* yield. Two bugs passed this gate: the omission of prime-power lines, and a modular inverse computed once instead of once per root. In both cases the prediction was built from the same simplified model as the code. A third issue, mixing logarithm bases when computing $u$, inflated $u$ and was caught during a smoke test. The two substantive bugs were found only by an independent brute-force recount. After the prime-power lines were restored, about $20\%$ more relations were recovered under the practical threshold. The general rule: **a gate whose prediction shares the implementation's assumptions cannot falsify those assumptions.**

---

## 6. From relations to a factor

### 6.1 The algebraic chain

**Proposition 6.1 (relations multiply to a congruence of squares).** For any finite family of integers $(x_i)_{i\in T}$,
$$N \;\Big|\; \Bigl(\prod_{i\in T} x_i\Bigr)^{2} - \prod_{i\in T}\bigl(x_i^2 - N\bigr).$$

*Proof.* Induction on $|T|$. Adding an index $j$ uses the identity
$$(x_j X)^2 - (x_j^2 - N)P = x_j^2\,(X^2 - P) + N P,$$
where $X = \prod_{i \in T} x_i$ and $P = \prod_{i \in T}(x_i^2 - N)$. $\square$

**Proposition 6.2 (existence of a square dependency).** Let $x_1,\dots,x_n$ be such that each $v_i = x_i^2 - N$ is a positive $B$-smooth integer. If $n > |\mathcal P(N,B)|$, then there is a nonempty $T \subseteq \{1,\dots,n\}$ and an integer $Y$ with $\prod_{i\in T} v_i = Y^2$, and therefore $N \mid (\prod_{i\in T} x_i)^2 - Y^2$.

*Proof sketch.* By Proposition 5.1 each $v_i$ is $\mathcal P(N,B)$-smooth. Its vector of exponent parities lies in $\mathbb F_2^{\mathcal P(N,B)}$. More than $\dim$ vectors are linearly dependent, and a dependency is a subset with all exponent sums even. Then apply Proposition 6.1. $\square$

**Proposition 6.3 (factor extraction).** If $N \mid X^2 - Y^2$, $N \nmid X - Y$ and $N \nmid X + Y$, then $1 < \gcd(X - Y, N) < |N|$.

*Proof.* Let $g = \gcd(X-Y, N)$. If $g = 1$, then $N$ is coprime to $X - Y$ and divides $(X-Y)(X+Y)$, so $N \mid X+Y$, a contradiction. If $g = |N|$, then $N \mid X - Y$, a contradiction. $\square$

**Theorem 6.4 (end-to-end).** If $\prod_{i\in T}(x_i^2 - N) = Y^2$ and $\prod x_i \not\equiv \pm Y \pmod N$, then $\gcd(\prod x_i - Y, N)$ is a proper divisor of $N$.

### 6.2 The Chinese Remainder coin flip

**Theorem 6.5 (four roots, two useful).** Let $p \neq q$ be odd primes and $y$ a unit modulo $pq$. Then $x^2 \equiv y^2 \pmod{pq}$ has exactly $4$ solutions modulo $pq$, and exactly $2$ of them satisfy $x \not\equiv \pm y$.

*Proof.* By the Chinese Remainder Theorem, $\mathbb Z/pq \cong \mathbb Z/p \times \mathbb Z/q$. In each field, $a^2 = b^2$ if and only if $a = \pm b$, and $b \neq -b$ for a nonzero $b$ in odd characteristic. So the solution set corresponds to $\{\pm y_p\} \times \{\pm y_q\}$, which has $4$ elements. Removing the two "diagonal" elements $(y_p,y_q) \leftrightarrow y$ and $(-y_p,-y_q) \leftrightarrow -y$ leaves $(y_p,-y_q)$ and $(-y_p,y_q)$. $\square$

Heuristically, if the square root $X$ produced by a dependency is uniformly distributed among the four roots of $X^2 \equiv Y^2$, each independent dependency factors $N$ with probability $1/2$, and $d$ independent dependencies fail with probability $2^{-d}$.

### 6.3 A complete certificate for $N = 103\,764\,863$

We sieved above $\lceil\sqrt N\rceil$ with the admissible factor base $\{2,11,17,19,23,31,37,43,47,59\}$. Note $N \equiv 7 \pmod 8$, so $2 \,\|\, Q(x)$ whenever $Q(x)$ is even (Proposition 3.5). Among the dependencies found by elimination over $\mathbb F_2$ were the following two.

**A trivial dependency.** For $x \in \{10342, 10749, 18185\}$,
$$\prod (x^2 - N) = 92\,360\,250\,334^2, \qquad N \mid 10342\cdot 10749 \cdot 18185 - 92\,360\,250\,334,$$
so $X \equiv Y$. This is one of the two useless roots of Theorem 6.5.

**A non-trivial dependency.**

| $x$ | $x^2 - N$ | factorization |
|---|---|---|
| $10248$ | $1\,256\,641$ | $19^2 \cdot 59^2$ |
| $10342$ | $3\,192\,101$ | $11^2 \cdot 23 \cdot 31 \cdot 37$ |
| $10749$ | $11\,776\,138$ | $2 \cdot 11 \cdot 17 \cdot 23 \cdot 37^2$ |
| $18185$ | $226\,929\,362$ | $2 \cdot 11 \cdot 17 \cdot 23^2 \cdot 31 \cdot 37$ |

The product is $2^2\cdot 11^4\cdot 17^2\cdot 19^2\cdot 23^4\cdot 31^2\cdot 37^4\cdot 59^2 = Y^2$ with $Y = 103\,535\,840\,624\,414$. With $X = \prod x_i = 20\,716\,911\,864\,941\,040$, neither $X - Y$ nor $X + Y$ is divisible by $N$, and
$$\gcd(X - Y,\, N) = 9127, \qquad N = 9127 \times 11369,$$
where both factors are prime.

**Remark (a Fermat shadow).** The first relation is a perfect square by itself: $10248^2 - N = 1121^2$. So $N = (10248 - 1121)(10248 + 1121) = 9127 \times 11369$ directly, which is Fermat's difference-of-squares method seen inside the sieve. The singleton $\{10248\}$ is a dependency of size one, and a full elimination over the relations reports it alongside the four-relation one. This happens because the two factors of the toy $N$ are close together ($11369/9127 \approx 1.25$), so $(p+q)/2 = 10248$ lies only about $62$ above $\sqrt N$, well inside the sieve window.

**Every relation in the certificate is non-squarefree.** By Corollary 2.5, a first-power sieve with an exact threshold would have rejected all four. The prime-power lines of Theorem 3.4 were therefore necessary for this factorization, not a small refinement.

---

## 7. Algorithms

**Algorithm A (Hensel line generation).** Input: odd prime $p \nmid N$ and height $K$. Compute $(N\mid p)$ by Euler's criterion. If it is $-1$, return no lines. Otherwise find $r$ with $r^2 \equiv N \pmod p$, using Tonelli–Shanks or brute force for small $p$. For $k = 1,\dots,K-1$, replace each root $x$ by $x - (x^2 - N)(2x)^{-1} \bmod p^{k+1}$. The inverse must be recomputed **for each root and each level**, which was one of the bugs in our ledger. Output: two residues per level. Cost: $O(K)$ modular inversions per prime.

**Algorithm B (log sieve with exact threshold).** Input: window $[a, a+M)$, admissible factor base, and height $K \ge \log_2 \max Q$. Initialize accumulators to $0$. For each $p$ and each level $k$, for each of the at most two roots $r$, add $\log p$ at positions $x \equiv r \pmod{p^k}$. Declare $x$ a survivor if the accumulator is at least $\log Q(x) - \varepsilon$. Trial-divide survivors only. Cost: Theorem 4.3 additions, plus $|\mathcal P|$ divisions per survivor.

**Algorithm C (dependency search and extraction).** Build parity vectors in $\mathbb F_2^{|\mathcal P|}$ and run Gaussian elimination, tracking combinations. For each dependency $T$, compute $X = \prod_{T} x_i \bmod N$ and $Y = \sqrt{\prod_T Q(x_i)} \bmod N$, using exponent halving. Return $\gcd(X - Y, N)$ if it is proper. Cost: $O(|\mathcal P|^2 n)$ bit operations for elimination.

---

## 8. Discussion

The picture that comes out of these measurements is short. **The sieve is a filter, and its input is a restricted population.**

1. The speed-up of sieving over trial division is the constant ratio between $\pi(B)$ divisions per value and a few additions per value. Theorem 4.3 bounds the second precisely, and Corollary 2.6 guarantees that the filter is exact once prime powers up to height $\log_2 v$ are sieved. No scale-dependent advantage appeared, and none is expected.
2. The yield is not that of random integers. Proposition 5.1 restricts the support to the admissible primes, a set of density $1/2$ among the primes, and Theorem 3.4 doubles the hit rate on that support. The effective-$u$ heuristic of Proposition 5.2 captures the first effect and not the second, which is why it explains the direction and trend of the H2 deviation (correlation $0.72$) but overshoots its size.
3. Repeated prime factors are common among smooth values of $Q$. The first-power bug discarded $54$–$91\%$ of relations under an exact threshold, and all four relations in our factoring certificate were non-squarefree.

**Scope.** The theorems in Sections 2–4 and 6 are exact and unconditional. The asymptotic yield law (Dickman-type behaviour of QR-restricted smooth numbers) is *not* proved here. Only the algebraic identity behind the effective-$u$ shift is. A rigorous version would need Mertens-type estimates restricted to a Chebotarev class in $\mathbb Q(\sqrt N)$.

---

## 9. Future work

1. **A QR-restricted Dickman law.** For non-square $N$ and $u \in [3,4]$, conjecture that the proportion of $x \in [\sqrt N, \sqrt N + M]$ with $x^2 - N$ $B$-smooth is asymptotic to $\rho_{1/2}(u)$, a "half-density" Dickman function solving $u\rho'(u) = -\tfrac12\rho(u-1)$, up to a local Euler-product correction. The admissible primes form a Chebotarev class of density $1/2$ in $\mathbb Q(\sqrt N)$, each hit with multiplicity $2$. Theorems 3.4 and 5.1 provide the two structural inputs a Buchstab recursion needs.
2. **A prime-power share law.** Conjecture that the fraction of smooth values $x^2 - N$ that are not squarefree converges, for fixed $u$, to an explicit constant $c(u) \in (0,1)$ given by an Euler product over admissible primes with local densities $2/p^2$, and that the corresponding exact-threshold loss decreases monotonically in $B$. Corollary 2.5 turns "lost relations" into "non-squarefree smooth", a multiplicative condition whose local densities $2/p^k$ are now theorems.
3. **Direct measurement at $u \in [3,4]$.** Compare smoothness of $x^2 - N$ directly against a QR-restricted reference pool, separating the support effect from the multiplicity effect.
4. **Many-dependency statistics.** Test the $2^{-d}$ failure law of Theorem 6.5 over many semiprimes.

---

## Appendix: worked numerical summary for $N = 103\,764\,863$, $B = 60$

A sieve over $M = 60\,000$ consecutive values above $\sqrt N$ with the $10$ admissible primes and full height finds exactly the $15$ smooth values that trial division by all $17$ primes up to $60$ finds. It uses about $1.3$ log additions per value, against about $18$ divisions per value for trial division, an advantage of about $14\times$. The first-power sieve keeps exactly the squarefree ones, which is $1$ of the $15$. For $y = 123456$, the four square roots of $y^2$ modulo $N$ are $123456$, $38\,894\,952$, $64\,869\,911$ and $103\,641\,407$. The two middle ones give $\gcd = 9127$ and $\gcd = 11369$ respectively.
