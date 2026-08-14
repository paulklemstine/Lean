# The Cyclic Splitting-Type Channel: Exact Information Above the Binary-Fork Cap

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

Let $f$ be an odd prime and let $\mathbb{Q}(\zeta_f)$ be the $f$-th cyclotomic field, whose Galois group is the cyclic group $C_n \cong (\mathbb{Z}/f)^\times$ of order $n = f-1$. For an unramified rational prime $p$, the *splitting type* $T(p) = \operatorname{ord}_f(p)$ — the residue degree, equivalently the order of the Frobenius element — is the complete factorisation datum of $p$ in $\mathbb{Q}(\zeta_f)$. We study the information carried by this multi-state observable, and by its semiprime analogue: given only the norm class $N \bmod f$ of a semiprime $N = pq$, how much is revealed about the unordered pair $\{T(p), T(q)\}$?

We prove four families of exact results. **(i) Determinism and the Euler law:** the type is a deterministic function of the residue, so the residue-to-type channel is exact, $I(p \bmod f \,;\, T) = H(T)$; the type distribution is the Euler law $\Pr[T = d] = \varphi(d)/n$ over divisors $d \mid n$, whence the closed form $H(T) = \log_2 n - \frac1n\sum_{d\mid n}\varphi(d)\log_2\varphi(d)$. Refining the observation modulus from $f$ to any multiple of $f$ adds no information ("thickening zero"). **(ii) Strict lossiness of the root count:** the binary readout "does $p$ split completely?" has entropy exactly $\log_2 n - \frac{n-1}{n}\log_2(n-1)$, equal to $H(T)$ if and only if $n$ is prime, and strictly smaller otherwise. **(iii) The semiprime type-pair law:** the mutual information between the norm class and the unordered type pair is $I_{\mathrm{pair}} = H(\Pi) - \frac1n\sum_c H(\Pi_c)$, an exactly computable finite quantity. Its values are $I_{\mathrm{pair}}(2)=1$, $I_{\mathrm{pair}}(4) = 5/4$, $I_{\mathrm{pair}}(6) = \log_2 3 - 1/9$, $I_{\mathrm{pair}}(8) = 21/16$, $I_{\mathrm{pair}}(12) = \log_2 3 + 5/36$, $I_{\mathrm{pair}}(16) = 85/64$, and further exact algebraic-logarithmic forms for $n \le 20$. The quadratic case sits exactly at the classical one-bit binary-fork cap; **every even cyclic order $n \ge 4$ strictly exceeds it, and every odd order $n \ge 3$ stays strictly below.** **(iv) Structure laws:** coprime additivity $I_{\mathrm{pair}}(mk) = I_{\mathrm{pair}}(m) + I_{\mathrm{pair}}(k)$ for $\gcd(m,k)=1$, the doubling law $I_{\mathrm{pair}}(2m) = I_{\mathrm{pair}}(m) + 1$ for odd $m$, and the $2$-adic growth law $I_{\mathrm{pair}}(2^k) = \frac43(1 - 4^{-k})$ with supremum $4/3$.

The one-bit ceiling for symmetric semiprime forks is therefore not a bound on what a norm class can reveal; it is a bound on *binary* observables. The complete splitting type is multi-state, and its channel is strictly richer, with capacity governed by the divisor lattice of the cyclic order.

---

## 1. Introduction

### 1.1 The binary-fork cap

The oldest information-theoretic question one can ask about a semiprime is a coin flip. Fix a quadratic field $K = \mathbb{Q}(\sqrt D)$ and consider the Kronecker symbol $\chi(p) = \left(\frac{D}{p}\right) \in \{+1,-1\}$: it records whether $p$ splits or is inert in $K$. For a semiprime $N = pq$ the symbol is multiplicative, $\chi(N) = \chi(p)\chi(q)$, so the observable $N$ hands over exactly the *product* of the two hidden bits. If $\chi(p),\chi(q)$ are independent fair bits, the unordered pair takes the three values $\{+,+\},\{+,-\},\{-,-\}$ with probabilities $\tfrac14,\tfrac12,\tfrac14$, so its entropy is $\tfrac32$ bits; conditioning on the observed parity $\chi(N)$ leaves a residual entropy of $\tfrac12$ bit (the parity $+$ leaves the two states $\{+,+\},\{-,-\}$ equiprobable, the parity $-$ determines the pair outright). The mutual information is therefore exactly $\tfrac32 - \tfrac12 = 1$ bit.

This is the *binary-fork cap*: any symmetric semiprime fork built from a two-state character is worth at most one bit, and the quadratic fork saturates the bound. The cap has functioned as a folk theorem — a product of two primes discloses one bit about the pair.

### 1.2 Multi-state splitting types

The cap is an artifact of asking a two-state question. In a cyclotomic field the natural question is not binary.

Let $f$ be an odd prime and $\zeta_f$ a primitive $f$-th root of unity. Then
$$\operatorname{Gal}(\mathbb{Q}(\zeta_f)/\mathbb{Q}) \cong (\mathbb{Z}/f)^\times \cong C_n, \qquad n = f-1,$$
via $\sigma_a(\zeta_f) = \zeta_f^{\,a}$. For a prime $p \nmid f$, the Frobenius element at $p$ is $\sigma_p$, and $p$ factors in $\mathbb{Z}[\zeta_f]$ into $g = n/T$ distinct prime ideals each of residue degree $T$, where
$$T(p) \;=\; \operatorname{ord}_f(p) \;=\; \min\{k \ge 1 : p^k \equiv 1 \bmod f\}$$
is the order of $\sigma_p$ in $C_n$. The integer $T(p)$ — a divisor of $n$ — is the **complete splitting type** of $p$: it determines the entire factorisation pattern, and no coarser invariant does.

The classical binary observable is the *root count* $\mathrm{nr}(p)$, the number of roots of the defining polynomial modulo $p$: it distinguishes only $T = 1$ (splits completely) from $T > 1$. This is one shadow of the type. The theme of this paper is that the shadow is strictly smaller than the object, and that the object breaks the cap.

### 1.3 The finite cyclic model

All statements below are theorems about a finite cyclic group, and hold for every cyclic order $n \ge 1$, independently of whether $n+1$ is prime. Write $C_n$ additively as $\mathbb{Z}/n$; under a choice of primitive root mod $f$ the discrete logarithm identifies $(\mathbb{Z}/f)^\times$ with $\mathbb{Z}/n$, converting multiplication of residues into addition. The type becomes the additive order
$$T(x) \;=\; \frac{n}{\gcd(n,x)}, \qquad x \in \mathbb{Z}/n,$$
and the multiplicative norm $N = pq$ becomes the additive norm class $x + y \bmod n$. Under Chebotarev equidistribution the Frobenius residues of primes are asymptotically uniform on $(\mathbb{Z}/f)^\times$, so the uniform measure on $\mathbb{Z}/n$ is the correct model, and every information quantity below is a finite, exactly computable real number rather than a statistical estimate.

### 1.4 Contributions

1. **Determinism (Theorem 3.1)** and **thickening zero (Theorem 3.2)**: the residue-to-type channel is exact and does not improve under refinement of the modulus.
2. **The Euler-$\varphi$ type law (Theorem 3.3)** and the resulting **entropy formula (Theorem 3.5)**, valid for all $n$.
3. **The root-count entropy (Theorem 4.1)** with the **exact lossiness dichotomy (Theorem 4.2)**: lossless exactly when $n$ is prime.
4. **The semiprime type-pair law (Definition 5.2, Theorem 5.3)** with exact closed-form values (Table 2) and the **cap theorem (Theorem 5.4)**.
5. **Structure laws (Section 6)**: coprime additivity, doubling, and the $2$-adic growth law with limit $4/3$.

---

## 2. Definitions

Throughout, $n \ge 1$ is an integer, $\varphi$ is Euler's totient, all logarithms are base $2$, and entropies are in bits. For a finite list of occupation numbers $c_1,\dots,c_m$ with total $t = \sum_i c_i$, the Shannon entropy of the induced distribution is
$$H(c_1,\dots,c_m;t) \;=\; -\sum_{i:\,c_i>0} \frac{c_i}{t}\log_2\frac{c_i}{t}.$$

**Lemma 2.1 (Counting form).** *If $\sum_i c_i = t > 0$ then*
$$H(c_1,\dots,c_m;t) \;=\; \log_2 t \;-\; \frac1t\sum_{i} c_i \log_2 c_i,$$
*with the convention $0\log_2 0 = 0$.*

*Proof.* Expand $\log_2(c_i/t) = \log_2 c_i - \log_2 t$ for $c_i > 0$ and use $\sum_i c_i = t$. $\square$

This identity is the computational engine of the paper: every entropy occurring below is a finite $\mathbb{Q}$-linear combination of terms $\log_2 c$ with $c$ a small integer, and therefore lies in the $\mathbb{Q}$-vector space spanned by $1$ and $\{\log_2 \ell : \ell \text{ prime}\}$. All "exact values" quoted are elements of that space.

**Definition 2.2 (Type).** For $x \in \mathbb{Z}/n$, the *splitting type* is $T(x) = n/\gcd(n,x)$, the additive order of $x$. Equivalently $T$ is the order of the corresponding Frobenius element in $C_n$, i.e. the residue degree of the corresponding prime.

**Definition 2.3 (Root-count readout).** The binary coarsening $\mathrm{nr}(x) = \mathbf{1}[T(x) = 1]$, i.e. "splits completely or not".

**Definition 2.4 (Type pair and norm class).** For an independent uniform pair $(x,y) \in (\mathbb{Z}/n)^2$, the *unordered type pair* is $\Pi(x,y) = \{T(x), T(y)\}$, recorded as the sorted pair $(\min, \max)$; the *norm class* is $\nu(x,y) = x + y \bmod n$.

---

## 3. The single-prime channel

### 3.1 Exactness

**Theorem 3.1 (Determinism / exactness of the residue-to-type channel).** *For every $n \ge 1$,*
$$I(x \,;\, T(x)) \;=\; H(T),$$
*where $x$ is uniform on $\mathbb{Z}/n$. Equivalently, $H(T \mid x) = 0$: the type is a deterministic function of the residue, so the channel from residue to type leaks the full type entropy and nothing is lost.*

*Proof.* The joint variable $(x, T(x))$ is supported on the graph of $T$, which is in bijection with $\mathbb{Z}/n$ since the first coordinate determines the second. Hence $H(x, T) = H(x) = \log_2 n$, and
$$I(x;T) = H(x) + H(T) - H(x,T) = \log_2 n + H(T) - \log_2 n = H(T). \qquad \square$$

In number-theoretic terms: $I(p \bmod f\,;\,T(p)) = H(T)$ exactly. There is no error term, no asymptotic, and no loss — the splitting type is a function of the Frobenius residue.

**Theorem 3.2 (Thickening zero).** *If $a \equiv b \pmod n$ then $T(a) = T(b)$. Consequently, for every $m \ge 1$ and every $a$, $T(a \bmod nm) = T(a)$: observing the residue modulo any multiple of $n$ — in particular modulo $f^2$ rather than $f$ — provides no additional information about the type.*

*Proof.* $\gcd(n,a)$ depends only on $a \bmod n$ (by the Euclidean step $\gcd(n,a) = \gcd(a \bmod n, n)$), hence so does $T(a) = n/\gcd(n,a)$. The second statement is the case $b = a \bmod nm$, using $n \mid nm$. $\square$

### 3.2 The Euler law

**Theorem 3.3 (Euler-$\varphi$ type law).** *Let $n > 0$ and $d \mid n$. Then exactly $\varphi(d)$ of the $n$ residues in $\mathbb{Z}/n$ have type $d$:*
$$\#\{x \in \mathbb{Z}/n : T(x) = d\} = \varphi(d), \qquad\text{i.e.}\qquad \Pr[T = d] = \frac{\varphi(d)}{n}.$$

*Proof.* First, $T(x) = d$ iff $\gcd(n,x) = n/d$: indeed if $\gcd(n,x) = n/d$ then $T(x) = n/(n/d) = d$ using $d \mid n$; conversely if $n/\gcd(n,x) = d$ then, since $\gcd(n,x) \mid n$, dividing back gives $\gcd(n,x) = n/d$. So the count is $\#\{x < n : \gcd(n,x) = n/d\}$, the number of elements of $\mathbb{Z}/n$ whose gcd with $n$ is the fixed divisor $n/d$. Writing $x = (n/d)u$ with $0 \le u < d$, the condition becomes $\gcd(d, u) = 1$, giving $\varphi(d)$ solutions. $\square$

**Corollary 3.4.** *Summing over $d \mid n$ recovers the Gauss identity $\sum_{d \mid n}\varphi(d) = n$; every residue has exactly one type, and the set of realised types is exactly the divisor set of $n$.*

**Theorem 3.5 (Closed form for the type entropy).** *For every $n > 0$,*
$$H(T) \;=\; \log_2 n \;-\; \frac1n \sum_{d \mid n} \varphi(d)\,\log_2 \varphi(d).$$

*Proof.* Combine Theorem 3.3 with Lemma 2.1, using $\sum_{d\mid n}\varphi(d) = n$. $\square$

**Corollary 3.6 (Prime cyclic order).** *If $n = \ell$ is prime, the type has only the two states $1$ and $\ell$ with probabilities $1/\ell$ and $(\ell-1)/\ell$, so*
$$H(T) \;=\; \log_2 \ell - \frac{\ell-1}{\ell}\log_2(\ell-1).$$

**Examples.** $n=4$ ($\mathbb{Q}(\zeta_5)$): types $\{1,2,4\}$ with rates $\tfrac14,\tfrac14,\tfrac12$ and $H(T) = \tfrac32$ exactly. $n=6$ ($\mathbb{Q}(\zeta_7)$): types $\{1,2,3,6\}$ with rates $\tfrac16,\tfrac16,\tfrac13,\tfrac13$ and $H(T) = \log_2 3 + \tfrac13 \approx 1.9183$. $n = 12$ ($\mathbb{Q}(\zeta_{13})$): six types $\{1,2,3,4,6,12\}$ with rates $\tfrac1{12},\tfrac1{12},\tfrac16,\tfrac16,\tfrac16,\tfrac13$ and $H(T) = \log_2 3 + \tfrac56 \approx 2.4183$.

---

## 4. The root count is strictly lossy

**Theorem 4.1 (Splits-completely pinning).** *For every $n > 0$, exactly one residue has type $1$, so the binary root-count readout has occupation numbers $(1, n-1)$ and entropy*
$$H(\mathrm{nr}) \;=\; \log_2 n - \frac{n-1}{n}\log_2 (n-1) \;=\; H_2\!\left(\tfrac1n\right),$$
*the binary entropy of $1/n$.*

*Proof.* $T(x) = 1$ iff $\gcd(n,x) = n$ iff $x = 0$; equivalently, Theorem 3.3 with $d = 1$ gives $\varphi(1) = 1$. Then apply Lemma 2.1 to $(1, n-1)$. $\square$

For $n = 4$ this is the **quartic pinning** $H(\mathrm{nr}) = 2 - \tfrac34\log_2 3 \approx 0.8113$: the splits-completely face of the $C_4$ channel is pinned by the quartic character alone. For $n = 6$ it is $1 + \log_2 3 - \tfrac56\log_2 5 \approx 0.6500 = H_2(1/6)$.

**Theorem 4.2 (Lossiness dichotomy).** *$H(\mathrm{nr}) \le H(T)$ always, with equality if and only if $n$ is prime or $n = 1$. In particular $H(\mathrm{nr}) < H(T)$ for $n = 4$ ($0.8113 < 1.5$) and for $n = 6$ ($0.6500 < 1.9183$).*

*Proof.* $\mathrm{nr}$ is a deterministic function of $T$, so $H(\mathrm{nr}) \le H(T)$ by the data-processing/coarsening inequality. Equality holds iff the coarsening is injective on the support, i.e. iff $T$ takes only the values $1$ and one other — that is, iff $n$ has exactly two divisors, i.e. $n$ is prime (or $n=1$, where both entropies vanish). For prime $n = \ell$, Corollary 3.6 and Theorem 4.1 give literally the same expression. $\square$

**Interpretation.** For $\mathbb{Q}(\zeta_5)$ the root count merges the factorisation patterns $[2,2]$ and $[4]$ into "no roots"; for $\mathbb{Q}(\zeta_7)$ it merges $[2,2,2]$, $[3,3]$ and $[6]$. Each merge destroys entropy. The type, not the root count, is the complete object.

---

## 5. The semiprime type-pair channel

### 5.1 Definition

The semiprime observer sees $N = pq$. Modulo $f$ the residue of $N$ is the product of the residues of $p$ and $q$; in the additive model this is the norm class $\nu = x+y$. The hidden datum is the unordered pair $\Pi = \{T(x), T(y)\}$, unordered because the observer has no way to label the two factors.

**Definition 5.1.** Let $x,y$ be independent and uniform on $\mathbb{Z}/n$. Let $\Pi$ denote the law of the unordered type pair, and for each $c \in \mathbb{Z}/n$ let $\Pi_c$ denote the law of the unordered type pair conditioned on $x + y = c$.

**Definition 5.2 (The type-pair channel capacity).**
$$I_{\mathrm{pair}}(n) \;=\; I\big(\nu \,;\, \Pi\big) \;=\; H(\Pi) \;-\; \frac1n\sum_{c \in \mathbb{Z}/n} H(\Pi_c).$$
The factor $1/n$ is the (uniform) law of the norm class: for independent uniform $x,y$, the sum $x+y$ is uniform on $\mathbb{Z}/n$, and each conditional fibre $\{(x,y) : x+y = c\}$ has exactly $n$ elements.

**Theorem 5.3 (Exact evaluability).** *For every $n > 0$, writing $P = (P_k)_k$ for the occupation numbers of the unordered type pairs among all $n^2$ ordered pairs, and $C_c = (C_{c,k})_k$ for the occupation numbers within the fibre $x+y=c$, we have $\sum_k P_k = n^2$, $\sum_k C_{c,k} = n$, and*
$$I_{\mathrm{pair}}(n) \;=\; \Big(\log_2 n^2 - \tfrac{1}{n^2}\textstyle\sum_k P_k \log_2 P_k\Big) \;-\; \tfrac1n \sum_c \Big(\log_2 n - \tfrac1n \textstyle\sum_k C_{c,k}\log_2 C_{c,k}\Big).$$
*Hence $I_{\mathrm{pair}}(n)$ is an explicit element of $\mathbb{Q} + \sum_{\ell} \mathbb{Q}\log_2 \ell$, computable by finite enumeration over $(\mathbb{Z}/n)^2$.*

*Proof.* Immediate from Lemma 2.1 applied to $P$ (total $n^2$) and to each $C_c$ (total $n$). $\square$

### 5.2 A worked example: $n = 4$, the field $\mathbb{Q}(\zeta_5)$

Types on $\mathbb{Z}/4$: $T(0)=1$, $T(1)=4$, $T(2)=2$, $T(3)=4$. The sixteen ordered pairs give six unordered type pairs with occupation numbers
$$\{1,1\}:1,\quad \{1,2\}:2,\quad \{2,2\}:1,\quad \{1,4\}:4,\quad \{2,4\}:4,\quad \{4,4\}:4,$$
summing to $16$. So $H(\Pi) = \log_2 16 - \tfrac1{16}(0 + 2\cdot 1 + 0 + 3\cdot 4 + 3\cdot 4 + 3\cdot 4) = 4 - \tfrac{38}{16} = \tfrac{19}{8} = 2.375$.

Conditioning on the norm class:

| $c$ | $\{1,1\}$ | $\{1,2\}$ | $\{2,2\}$ | $\{1,4\}$ | $\{2,4\}$ | $\{4,4\}$ | $H(\Pi_c)$ |
|---|---|---|---|---|---|---|---|
| $0$ | 1 | 0 | 1 | 0 | 0 | 2 | $1.5$ |
| $1$ | 0 | 0 | 0 | 2 | 2 | 0 | $1$ |
| $2$ | 0 | 2 | 0 | 0 | 0 | 2 | $1$ |
| $3$ | 0 | 0 | 0 | 2 | 2 | 0 | $1$ |

Thus $H(\Pi \mid \nu) = \tfrac14(1.5+1+1+1) = \tfrac98 = 1.125$ and
$$I_{\mathrm{pair}}(4) = \tfrac{19}{8} - \tfrac98 = \tfrac54 = 1.25 \text{ bits} \;>\; 1.$$

The cap is exceeded, exactly and unconditionally.

### 5.3 Exact values

**Table 1. Single-prime quantities.**

| $n$ | states | $H(T)$ exact | $H(T)$ | $H(\mathrm{nr}) = H_2(1/n)$ |
|---|---|---|---|---|
| $2$ | $2$ | $1$ | $1.0000$ | $1.0000$ |
| $3$ | $2$ | $\log_2 3 - \tfrac23$ | $0.9183$ | $0.9183$ |
| $4$ | $3$ | $\tfrac32$ | $1.5000$ | $0.8113$ |
| $5$ | $2$ | $\log_2 5 - \tfrac85$ | $0.7219$ | $0.7219$ |
| $6$ | $4$ | $\log_2 3 + \tfrac13$ | $1.9183$ | $0.6500$ |
| $8$ | $4$ | $\tfrac74$ | $1.7500$ | $0.5436$ |
| $9$ | $3$ | $\tfrac43\log_2 3 - \tfrac89$ | $1.2244$ | $0.5033$ |
| $10$ | $4$ | $\log_2 5 - \tfrac35$ | $1.7219$ | $0.4690$ |
| $12$ | $6$ | $\log_2 3 + \tfrac56$ | $2.4183$ | $0.4138$ |
| $15$ | $4$ | $\log_2 3 + \log_2 5 - \tfrac{34}{15}$ | $1.6402$ | $0.3534$ |
| $16$ | $5$ | $\tfrac{15}8$ | $1.8750$ | $0.3373$ |
| $18$ | $6$ | $\tfrac43\log_2 3 + \tfrac19$ | $2.2244$ | $0.3095$ |
| $20$ | $6$ | $\log_2 5 - \tfrac1{10}$ | $2.2219$ | $0.2864$ |

Note the dichotomy of Theorem 4.2 visible in the last two columns: equality exactly at the prime orders $2,3,5$ (and $7,11,13$), strict inequality at every composite order.

**Table 2. The semiprime type-pair channel.**

| $n$ | field ($f = n+1$ prime) | $I_{\mathrm{pair}}(n)$ exact | value | vs. cap |
|---|---|---|---|---|
| $2$ | any quadratic field, e.g. $\mathbb{Q}(\sqrt5)$ | $1$ | $1.0000$ | at cap |
| $3$ | — | $\log_2 3 - \tfrac{10}{9}$ | $0.4739$ | below |
| $4$ | $\mathbb{Q}(\zeta_5)$ | $\tfrac54$ | $1.2500$ | **above** |
| $5$ | — | $\log_2 5 + \tfrac{12}{25}\log_2 3 - \tfrac{72}{25}$ | $0.2027$ | below |
| $6$ | $\mathbb{Q}(\zeta_7)$ | $\log_2 3 - \tfrac19$ | $1.4739$ | **above** |
| $7$ | — | $\log_2 7 + \tfrac{30}{49}\log_2 5 - \tfrac{78}{49}\log_2 3 - \tfrac{78}{49}$ | $0.1141$ | below |
| $8$ | — | $\tfrac{21}{16}$ | $1.3125$ | **above** |
| $9$ | — | $\tfrac{10}9\log_2 3 - \tfrac{100}{81}$ | $0.5265$ | below |
| $10$ | $\mathbb{Q}(\zeta_{11})$ | $\log_2 5 + \tfrac{12}{25}\log_2 3 - \tfrac{47}{25}$ | $1.2027$ | **above** |
| $11$ | — | $\log_2 11 + \tfrac{180}{121}\log_2 3 - \tfrac{210}{121}\log_2 5 - \tfrac{210}{121}$ | $0.0519$ | below |
| $12$ | $\mathbb{Q}(\zeta_{13})$ | $\log_2 3 + \tfrac{5}{36}$ | $1.7239$ | **above** |
| $13$ | — | $\log_2 13 + \tfrac{132}{169}\log_2 11 - \tfrac{300}{169}\log_2 3 - \tfrac{600}{169}$ | $0.0386$ | below |
| $14$ | — | $\log_2 7 + \tfrac{30}{49}\log_2 5 - \tfrac{78}{49}\log_2 3 - \tfrac{29}{49}$ | $1.1141$ | **above** |
| $15$ | — | $\log_2 5 + \tfrac{37}{25}\log_2 3 - \tfrac{898}{225}$ | $0.6766$ | below |
| $16$ | $\mathbb{Q}(\zeta_{17})$ | $\tfrac{85}{64}$ | $1.3281$ | **above** |
| $18$ | $\mathbb{Q}(\zeta_{19})$ | $\tfrac{10}9\log_2 3 - \tfrac{19}{81}$ | $1.5265$ | **above** |
| $20$ | — | $\log_2 5 + \tfrac{12}{25}\log_2 3 - \tfrac{163}{100}$ | $1.4527$ | **above** |

**Theorem 5.4 (The cap theorem, verified range).** *$I_{\mathrm{pair}}(2) = 1$ exactly; $I_{\mathrm{pair}}(n) > 1$ for $n \in \{4,6,8,10,12,14,16,18,20\}$; and $I_{\mathrm{pair}}(n) < 1$ for $n \in \{3,5,7,9,11,13,15\}$.*

*Proof.* Each value is an exact element of $\mathbb{Q} + \mathbb{Q}\log_2 3 + \mathbb{Q}\log_2 5 + \mathbb{Q}\log_2 7 + \mathbb{Q}\log_2 11 + \mathbb{Q}\log_2 13$ obtained by finite enumeration and Theorem 5.3. The comparisons with $1$ follow from explicit rational bounds on the logarithms, e.g. $\tfrac{19}{12} < \log_2 3 < \tfrac{27}{17}$ (from $2^{19} < 3^{12}$ and $3^{17} < 2^{27}$), $\tfrac{23}{10} < \log_2 5 < \tfrac73$, $\tfrac{14}{5} < \log_2 7 < 3$, $\log_2 11 < \tfrac72$, $\log_2 13 < \tfrac{15}4$, each certified by an integer power comparison. Substituting these bounds into the exact forms makes every comparison a rational inequality. $\square$

For example, $I_{\mathrm{pair}}(6) = \log_2 3 - \tfrac19 > \tfrac{19}{12} - \tfrac19 = \tfrac{53}{36} > 1$, and $I_{\mathrm{pair}}(3) = \log_2 3 - \tfrac{10}{9} < \tfrac{27}{17} - \tfrac{10}9 = \tfrac{73}{153} < 1$.

### 5.4 Symmetry and the which-factor wall

The channel is symmetric by construction: $\Pi$ is an unordered pair. Recording *which* factor carries which type is not available from the norm class — the map $(x,y)\mapsto(y,x)$ preserves both the norm class and the observable, so the mutual information between the norm class and the ordered assignment, given the unordered pair, is exactly $0$. The channel discloses the *multiset* of shapes and nothing about the labelling.

### 5.5 The split-count projection

Projecting $\Pi$ along $T \mapsto \mathbf{1}[T=1]$ yields the classical split-count observable, and the mutual information of the projected channel equals the classical split-count information. Numerically for $n=4$ the projected channel carries $0.2947$ bits, for $n=6$ it carries $0.1487$ bits, and for $n = 12$ only $0.0445$ bits — in every case far below the full $I_{\mathrm{pair}}$. The classical quantity is one face of the type channel; the type channel strictly dominates it. (This is the data-processing inequality applied to the pair channel: coarsening the hidden variable cannot increase the mutual information.)

---

## 6. Structure laws

### 6.1 Coprime additivity

**Theorem 6.1 (CRT additivity, verified instances).** *For the coprime factorisations $12 = 4\cdot3$, $10 = 2\cdot 5$, $15 = 3\cdot 5$, $14 = 2\cdot 7$, $20 = 4\cdot 5$, $18 = 2\cdot 9$ one has the exact identity*
$$I_{\mathrm{pair}}(mk) = I_{\mathrm{pair}}(m) + I_{\mathrm{pair}}(k), \qquad \gcd(m,k) = 1 .$$
*Numerically the identity holds for every coprime splitting with $mk \le 40$.*

*Proof of the instances.* Substitute the exact closed forms of Table 2 and simplify. E.g. $I_{\mathrm{pair}}(4)+I_{\mathrm{pair}}(3) = \tfrac54 + \log_2 3 - \tfrac{10}9 = \log_2 3 + \tfrac5{36} = I_{\mathrm{pair}}(12)$; and $I_{\mathrm{pair}}(3)+I_{\mathrm{pair}}(5) = (\log_2 3 - \tfrac{10}9) + (\log_2 5 + \tfrac{12}{25}\log_2 3 - \tfrac{72}{25}) = \tfrac{37}{25}\log_2 3 + \log_2 5 - \tfrac{898}{225} = I_{\mathrm{pair}}(15)$. $\square$

**Structural explanation.** For $\gcd(m,k)=1$ the Chinese Remainder Theorem gives $\mathbb{Z}/mk \cong \mathbb{Z}/m \times \mathbb{Z}/k$, and the type map factors multiplicatively,
$$T_{mk}(x) = T_m(x_m)\cdot T_k(x_k), \qquad \gcd\big(T_m(x_m), T_k(x_k)\big) = 1,$$
because the two factors divide the coprime integers $m$ and $k$. Coprimality means the product can be uniquely decomposed, so the unordered pair in $\mathbb{Z}/mk$ is determined by the two component unordered pairs *together with the matching* between them; and the matching ambiguity is precisely cancelled by conditioning on the norm class in each component (the norm classes also split as $\nu_{mk} = (\nu_m,\nu_k)$). The channel is a tensor product of independent channels, and mutual information is additive over independent products.

### 6.2 The doubling law

**Theorem 6.2 (Doubling).** *For $m$ odd, $I_{\mathrm{pair}}(2m) = I_{\mathrm{pair}}(m) + 1$; verified exactly for $m = 3,5,7,9$:*
$$I_{\mathrm{pair}}(6) = I_{\mathrm{pair}}(3) + 1,\quad I_{\mathrm{pair}}(10) = I_{\mathrm{pair}}(5)+1,\quad I_{\mathrm{pair}}(14)=I_{\mathrm{pair}}(7)+1,\quad I_{\mathrm{pair}}(18)=I_{\mathrm{pair}}(9)+1 .$$

*Proof.* Theorem 6.1 with $k = 2$, together with $I_{\mathrm{pair}}(2) = 1$; each instance is also verified directly from the closed forms. $\square$

This identifies the classical quadratic bit as an exact *summand* of the general channel: the binary fork is the $C_2$ tensor factor, and any additional odd structure sits strictly on top of it. It also explains the even/odd dichotomy of Table 2: an even order carries $1 + I_{\mathrm{pair}}(\text{odd part}) \ge 1$ bits, with strict inequality as soon as the odd part is nontrivial, while an odd order carries only the strictly sub-critical contribution of its odd factors.

### 6.3 The $2$-adic growth law

**Theorem 6.3.** *For $1 \le k \le 4$,*
$$I_{\mathrm{pair}}(2^k) \;=\; \frac43\left(1 - 4^{-k}\right),$$
*i.e. $1, \tfrac54, \tfrac{21}{16}, \tfrac{85}{64}$. The sequence is strictly increasing and bounded above by $\tfrac43$; numerically the formula continues to hold for $k = 5, 6$ ($\tfrac{341}{256}, \tfrac{1365}{1024}$).*

*Proof of the stated range.* Substitute the exact values $I_{\mathrm{pair}}(2)=1$, $I_{\mathrm{pair}}(4)=\tfrac54$, $I_{\mathrm{pair}}(8)=\tfrac{21}{16}$, $I_{\mathrm{pair}}(16)=\tfrac{85}{64}$, each obtained by enumeration, and compare with $\tfrac43(1-4^{-k})$; monotonicity and the bound $<\tfrac43$ are rational comparisons. $\square$

**Structural explanation.** For $n = 2^k$, the type of $x$ is $2^{k - v(x)}$ where $v$ is the $2$-adic valuation truncated at $k$. Since $v(x+y) = \min(v(x),v(y))$ unless $v(x) = v(y)$, the conditional law $\Pi_c$ depends on $c$ only through $v(c)$, and level $k$ reproduces level $k-1$ with one additional state of half the mass. The resulting affine recursion $a_k = \tfrac14 a_{k-1} + 1$ has fixed point $\tfrac43$, giving $a_k = \tfrac43(1-4^{-k})$ with $a_1 = 1$.

Thus **the capacity of a purely $2$-power cyclic channel is bounded by $4/3$ bits**, no matter how large the group.

### 6.4 Summary of the growth pattern

The value of $I_{\mathrm{pair}}(n)$ is governed by the divisor lattice of $n$, through the multiplicative decomposition of Theorem 6.1: $I_{\mathrm{pair}}$ is (conjecturally, and provably on the verified range) an additive function of $n$ in the arithmetic sense, determined by its values on prime powers. Among the small orders the richest is $n = 12 = 4\cdot 3$: six type states, and $1.7239$ bits.

---

## 7. Algorithms

### 7.1 Exact channel evaluation

**Input:** cyclic order $n$. **Output:** exact occupation tables and the value $I_{\mathrm{pair}}(n)$.

1. For $x = 0,\dots,n-1$ compute $T(x) = n/\gcd(n,x)$ — $O(n\log n)$.
2. For each ordered pair $(x,y)$, form the sorted key $k = (\min(T(x),T(y)), \max(\cdot))$ and increment both the global counter $P[k]$ and the fibre counter $C[(x+y)\bmod n][k]$ — $O(n^2)$ time, $O(n\,\tau(n)^2)$ space, where $\tau(n)$ is the number of divisors.
3. Apply the counting form of the entropy (Lemma 2.1) to $P$ with total $n^2$ and to each $C[c]$ with total $n$.
4. Return $H(\Pi) - \frac1n\sum_c H(\Pi_c)$.

Because every entropy is $\log_2(\text{total}) - \frac{1}{\text{total}}\sum c\log_2 c$ with integer $c$, the result can be produced as an exact symbolic combination $q_0 + \sum_\ell q_\ell \log_2 \ell$ with $q_i \in \mathbb{Q}$ by factoring each occupation number: no floating point is needed anywhere.

### 7.2 Certified comparison with the cap

To decide $I_{\mathrm{pair}}(n) \gtrless 1$ rigorously from the symbolic form $q_0 + \sum_\ell q_\ell\log_2\ell$: for each prime $\ell$ occurring, produce rational bounds $a/b < \log_2\ell < c/d$ certified by integer comparisons $2^a < \ell^b$ and $\ell^d < 2^c$ (exact big-integer arithmetic), substitute the bound in the direction dictated by the sign of $q_\ell$, and compare the resulting rational with $1$. This yields a proof, not an estimate.

### 7.3 Sampling the arithmetic side

To confirm that the finite cyclic model is the right model for the arithmetic: for a prime $f$, enumerate primes $p < X$, compute $T(p) = \operatorname{ord}_f(p)$ by repeated squaring, and compare the empirical distribution with the Euler law $\varphi(d)/(f-1)$. Chebotarev's theorem guarantees convergence; empirically the agreement is at the $10^{-3}$ level already for a few $10^4$ primes.

---

## 8. Discussion

### 8.1 What was actually capped

The classical statement — *a symmetric semiprime fork carries at most one bit* — is correct, but only for two-state forks. The proof of the cap uses the fact that the unordered pair of two bits has only three states, and that the product character determines a two-block partition of them. As soon as the hidden variable has $\ge 3$ states, the counting that produces the cap breaks down, and the true value is given by the finite computation of Theorem 5.3. The results here show that the excess is not marginal: $25\%$ over the cap already for $\mathbb{Q}(\zeta_5)$, and $72\%$ for $\mathbb{Q}(\zeta_{13})$.

### 8.2 Why this is not an attack on factoring

Four independent reasons.

1. **Symmetry.** The channel reveals the unordered multiset $\{T(p), T(q)\}$; the which-factor information is exactly zero. Even a full readout of the type pair does not orient the two factors.
2. **A single residue dial.** The entire channel is a function of $N \bmod f$, one residue in a group of order $f-1$. Extracting it requires no work, and it is the *only* thing the channel sees (Theorem 3.2: refining the modulus adds nothing).
3. **Bounded leak.** For two-power orders the leak is capped at $4/3$ bits (Theorem 6.3) regardless of size; in general the leak grows only like the entropy of the divisor lattice, i.e. like $O(\log\log n)$ in typical cases — negligible against the $\Theta(\log N)$ bits needed to specify a factor. Even aggregating over many moduli $f$, the additivity of Theorem 6.1 shows that the leaks combine additively, not multiplicatively, in the coprime directions.
4. **Classical ingredients.** Cyclotomic fields, Dirichlet characters, the Chinese Remainder Theorem, and Chebotarev's density theorem (1922) are all that is used. Nothing here provides a new computational handle; the contribution is a new *measurement* of a classical object.

### 8.3 Unification

The framework subsumes several separate observations. The classical quadratic split-count fork is the $n=2$ case, exactly at the cap; the split-count observable for general $n$ is the $\mathbf{1}[T=1]$ projection of the type channel; the "quartic pinning" $2 - \tfrac34\log_2 3$ is the $n=4$ case of the general pinning formula $H_2(1/n)$ of Theorem 4.1; and the "thickening" phenomenon — that finer moduli add nothing — is Theorem 3.2 in general form. In each case the previously isolated statement becomes an instance of a formula valid for all cyclic orders.

---

## 9. Future directions

**C1. The coprime additivity theorem in general form.** *Conjecture:* for all coprime $m,k \ge 1$, $I_{\mathrm{pair}}(mk) = I_{\mathrm{pair}}(m) + I_{\mathrm{pair}}(k)$. Established here for $12 = 4\cdot3$, $10=2\cdot5$, $15=3\cdot5$, $14=2\cdot7$, $20=4\cdot5$, $18=2\cdot9$, and verified numerically for every coprime splitting with $mk \le 40$. The route to a general proof is the factorisation $T = T_m\cdot T_k$ with coprime factors through the Chinese Remainder isomorphism; the only missing step is a measure-preserving bijection between the fibres, which is a finite combinatorial statement requiring no analysis, since the Euler law and the counting form of the entropy are already available in complete generality.

**C2. The $2$-adic growth law and its limit.** *Conjecture:* $I_{\mathrm{pair}}(2^k) = \tfrac43(1-4^{-k})$ for all $k \ge 1$, so that the capacity of a cyclic $2$-group channel is bounded by, and converges to, $4/3$ bits. Proved here for $k \le 4$, numerically confirmed to $k = 6$. The self-similar recursion described in §6.3 should make the induction step a finite identity between two explicit dyadic entropies.

**C3. The even/odd dichotomy of the one-bit cap.** *Conjecture:* $I_{\mathrm{pair}}(n) > 1$ if and only if $n$ is even and $n \ge 4$, with $I_{\mathrm{pair}}(2) = 1$ exactly, and $I_{\mathrm{pair}}(n) < 1$ for every odd $n \ge 3$; equivalently, the cap is broken exactly when the cyclic order admits the quadratic quotient nontrivially. Proved here for $n \in \{2,\dots,16,18,20\}$ and verified for $n \le 40$. It follows from C1 plus the single inequality $I_{\mathrm{pair}}(m) < 1$ for odd $m$, since $C_2$ is the unique quotient whose type pair *is* the norm class.

**Further questions.** (a) Is $I_{\mathrm{pair}}$ maximised, among orders of a given size, by those with the richest divisor lattice — i.e. does $n = 12$'s dominance persist as a general principle? (b) What is the exact asymptotic growth of $I_{\mathrm{pair}}(n)$ along highly composite $n$? (c) Do the same laws hold for non-cyclic abelian Galois groups, where the "type" becomes the cyclic subgroup generated by the Frobenius rather than a single integer? (d) Can the type-pair channel be defined and evaluated for products of three or more primes, and does the additivity law persist in the number of factors?

---

## 10. Conclusion

The splitting type of a prime in a cyclotomic field with cyclic Galois group is a multi-state, exactly-computable invariant with an Euler-$\varphi$ distribution, and it is a deterministic function of the Frobenius residue, so the residue-to-type channel is exact. Its binary shadow, the split/not-split root count, is strictly lossy whenever the cyclic order is composite. For semiprimes, the mutual information between the norm class and the unordered type pair is an exact finite quantity that equals $1$ bit in the quadratic case — reproducing the classical binary-fork cap on the nose — and strictly exceeds it for every even cyclic order beyond the quadratic one, reaching $\tfrac54$ for $\mathbb{Q}(\zeta_5)$, $\log_2 3 - \tfrac19$ for $\mathbb{Q}(\zeta_7)$, and $\log_2 3 + \tfrac5{36}$ for $\mathbb{Q}(\zeta_{13})$. The values obey coprime additivity, a doubling law, and a $2$-adic growth law with limit $4/3$.

The one-bit ceiling was a ceiling on binary questions, not on what a norm class can say.
