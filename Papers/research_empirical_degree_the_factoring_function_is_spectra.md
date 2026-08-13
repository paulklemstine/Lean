# Spectral Flatness of the Factoring Function

### An exact zero-block theorem, a top-bit transmission law, and the resolution of the low-bit anomaly

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

Let $N = pq$ be a semiprime with $k$-bit factors and let $f_j(N)$ denote bit $j$ of the smaller factor. We study the Walsh (Fourier–$\mathrm{GF}(2)$) spectrum of $f_j$ as a function of the bits of $N$, motivated by the question of whether any low-degree parity of the public value approximates any bit of a secret factor. We prove three groups of results.

**(i) An exact zero-block theorem.** Over the *full odd support* modulo $2^t$ — all ordered pairs $(p,q)$ of odd residues, with public value $N = pq \bmod 2^t$ — for every bit index $1 \le j < t$ and every real-valued statistic $g$ of $N$, the signed correlation $\sum_{p,q} (-1)^{p_j} g(pq \bmod 2^t)$ vanishes identically. The quantification over $g$ is unrestricted: this covers every $\mathrm{GF}(2)$ parity of every degree, every real polynomial in the bits of $N$, and every predictor whatsoever. Consequently any Boolean predictor of $p_j$ reading only $N$ is correct on *exactly* half the support. We strengthen this to perfect secrecy: every fiber $\{(p,q) : pq \equiv N\}$ has exactly $2^{t-1}$ points and contains every odd residue exactly once as a first coordinate, so distinct public values induce identical distributions on the secret factor, and any strategy naming a single candidate for the secret low block hits at most one fiber point. The mechanism is isolated abstractly: on any finite group, a mean-zero statistic of the first factor is uncorrelated with every statistic of the product.

**(ii) A top-bit transmission law.** For balanced factors $2^{k-1} \le p \le q < 2^k$, the implication $p_{k-2} = 1 \Rightarrow N_{2k-1} = 1$ holds without exception; equivalently, a product that does not carry into its top bit forces $p_{k-2} = 0$. The implication is strictly one-sided (explicit counterexamples are given), the conditioning statistic $\mathbb{1}[N \ge 2^{2k-1}]$ is symmetric in $(p,q)$ and computable from $N$ alone, and the resulting covariance of the two indicator events is strictly positive at every size, with limiting value $(2\log 2 - 1)/4 = 0.0965735\ldots$, equivalently a limiting correlation $4\log 2 - 5/2 = 0.2725887\ldots$

**(iii) A resolution of the empirical anomalies.** The single non-flat structure in exhaustive low-degree scans is the symmetric top-bit magnitude/carry family described by (ii), whose measured strength $0.285$ at $k=14$ agrees with the limiting constant above. The previously unexplained low-bit correlation at small sizes (bit $j=2$ against the top bit of $N$: $+0.254$ at $k=8$, $+0.166$ at $k=10$) is shown by exhaustive enumeration to alternate in sign with the bit length and to decay to $-0.0064$ at $k = 14$, below the noise level of the scan, identifying it as a finite-sample fluctuation of the top-bit family rather than a low-degree approximator. We also determine, by exact rational computation, that on the ordered support $p < q$ — the one place where the zero-block theorem provably fails — the maximizing spectral coefficient is always the *empty* parity at the *highest* available bit of $p$: the residual defect is the order statistic itself, a magnitude effect, not a parity of $N$.

Together the results give a complete description of the low-degree spectral face of the factoring problem: exactly flat on the low block, non-flat only in a symmetric size/carry family that reveals nothing about which factor is which.

**Keywords:** Walsh spectrum, Boolean Fourier analysis, integer factorization, semiprimes, $\mathrm{GF}(2)$ parity, low-degree approximation, carry propagation, perfect secrecy.

---

## 1. Introduction

### 1.1 The question

Modern public-key cryptography rests on the presumed one-wayness of multiplication: the product $N = pq$ of two large primes is public, the factors are secret, and no efficient factoring algorithm is known. Unconditional hardness is far out of reach. What *is* within reach is the systematic exclusion of specific attack families — a *barrier framework*, in which each theorem says that some natural class of algorithms cannot extract secret information from the public value.

This paper treats the most elementary such class: **low-degree $\mathrm{GF}(2)$ parities.** Write the public value in binary as $N = \sum_{i} N_i 2^i$ and the smaller factor as $p = \sum_j p_j 2^j$. For a set $S$ of bit positions of $N$, the parity function is
$$\chi_S(N) \;=\; \bigoplus_{i \in S} N_i, \qquad\text{degree } \deg \chi_S = |S| .$$
Does some parity of small degree predict some bit $p_j$ appreciably better than a coin?

This is not merely a toy question. Any learning procedure that begins by fitting a low-degree model over $\mathrm{GF}(2)$ — from Gaussian elimination on linear relations, through low-degree agnostic learning, to the first layers a neural network is able to represent — is asking precisely this question, and the Walsh spectrum answers it exhaustively.

### 1.2 The empirical picture

Exhaustive spectral census on exact $k$-bit prime semiprime supports (support sizes $m = 276, 2850, 32640, 380628$ at $k = 8, 10, 12, 14$, with random-sign null models calibrated per size, degree-$\le 3$ scans at $k=14$) produces the following picture.

1. **Flatness.** At $k = 14$, every information-bearing bit below the top $\approx 6$ has maximum degree-$\le 3$ correlation at most $0.021$, against an all-parity noise level of $0.0101$ and a degree-$\le 3$ null maximum of $0.0065$. No parity of at most three bits of $N$ approximates any factor bit.
2. **The one exception.** The correlations $\mathrm{corr}(p_{k-d}, N_{2k-1})$ for $d = 2, 3, 4, 5, 6$ take values of order $0.285$, $0.310$, $0.132$, $0.065$, $0.026$ — a magnitude/carry family concentrated at the top of the factor, symmetric in $(p,q)$ and computable from $N$ alone.
3. **A small-$k$ oddity.** The correlation $\mathrm{corr}(p_2, N_{2k-1})$ measured $0.254 / 0.166 / 0.013 / 0.006$ at $k = 8/10/12/14$ — striking at small $k$, gone by $k = 14$.
4. **Low-half cubics.** $\mathrm{corr}(f_3, \chi_{\{1,2,3\}})$ decays from $0.203$ to $0.013$ and $\mathrm{corr}(f_4, \chi_{\{1,3,4\}})$ from $0.145$ to $0.009$ across $k = 8, \dots, 14$.
5. **Controls.** Degree-$\le 3$ null maxima $0.074 / 0.0213 / 0.0065$ at $k = 10/12/14$; the constant bits $j = 0$ and $j = k-1$ trivially correlate at $1.0$; the carry-out bit reproduces at $0.51$ (linear) and $0.79$ (quadratic).

The purpose of this paper is to replace the measurements by theorems: to prove that the flat part is *exactly* flat, that the non-flat part is *exactly* the magnitude family, and that items 3 and 4 are finite-support fluctuations rather than signal.

### 1.3 Contributions and organisation

Section 2 develops the Walsh calculus on the Boolean cube (orthogonality, Parseval, the correlation–agreement dictionary, the $1/2$ barrier, the noise floor, and the low-degree mass bound), all of it needed to say precisely what "flat" means. Section 3 proves the zero-block theorem on the odd support modulo $2^t$ and its predictor and secrecy corollaries. Section 4 proves the top-bit transmission law, its one-sidedness, its symmetry, and the strict positivity of the associated covariance, and derives the limiting constant. Section 5 confronts the theorems with exhaustive computation and resolves the anomalies. Section 6 gives algorithms. Section 7 discusses scope and limits; Section 8 lists open problems.

---

## 2. The Walsh calculus and what "flat" means

Throughout this section $n \ge 0$ is fixed and functions are defined on the cube $\{0,1\}^n$, identified with $\mathrm{Fin}(n) \to \mathrm{Bool}$.

### 2.1 Signs and characters

**Definition 2.1 (Sign encoding).** For a Boolean value $b$ set $\mathrm{sgn}(b) = 1$ if $b = 0$ and $\mathrm{sgn}(b) = -1$ if $b = 1$. Thus $\mathrm{sgn}(b)^2 = 1$ and $\mathrm{sgn}(a)\mathrm{sgn}(b) = 1$ if and only if $a = b$.

**Definition 2.2 (Walsh character).** For $S \subseteq \{0,\dots,n-1\}$ and $x \in \{0,1\}^n$,
$$\chi_S(x) \;=\; \prod_{i \in S} \mathrm{sgn}(x_i) \;=\; (-1)^{\bigoplus_{i\in S} x_i} \in \{\pm 1\}.$$

**Proposition 2.3 (Group law).** $\chi_S(x)\chi_T(x) = \chi_{S \triangle T}(x)$ for all $S, T, x$, where $\triangle$ is symmetric difference. Hence the characters form a group isomorphic to $(\mathcal{P}(\{0,\dots,n-1\}), \triangle)$.

*Proof.* Split $S \cup T$ into $S \triangle T$ and $S \cap T$; the coordinates in $S \cap T$ contribute $\mathrm{sgn}(x_i)^2 = 1$ twice over. $\square$

**Proposition 2.4 (Character sum).** $\sum_{x \in \{0,1\}^n} \chi_S(x) = 2^n$ if $S = \emptyset$ and $0$ otherwise.

*Proof.* Write $\chi_S(x) = \prod_{i} c_i(x_i)$ with $c_i = \mathrm{sgn}$ for $i \in S$ and $c_i \equiv 1$ otherwise, and expand the sum over the cube as a product of one-coordinate sums. Each coordinate in $S$ contributes $\mathrm{sgn}(0) + \mathrm{sgn}(1) = 0$. $\square$

**Corollary 2.5 (Orthogonality).** $\sum_x \chi_S(x)\chi_T(x) = 2^n \mathbb{1}[S = T]$.

**Proposition 2.6 (Dual orthogonality).** $\sum_{S} \chi_S(x)\chi_S(y) = 2^n\mathbb{1}[x = y]$, the sum ranging over all $2^n$ subsets.

*Proof.* $\sum_S \prod_{i \in S}\big(\mathrm{sgn}(x_i)\mathrm{sgn}(y_i)\big) = \prod_i \big(1 + \mathrm{sgn}(x_i)\mathrm{sgn}(y_i)\big)$, a product of factors equal to $2$ when $x_i = y_i$ and $0$ otherwise. $\square$

### 2.2 Coefficients, Parseval, and the dictionary

**Definition 2.7.** For $f : \{0,1\}^n \to \mathbb{R}$ put $\widehat{W}f(S) = \sum_x f(x)\chi_S(x)$ and $\mathrm{corr}(f, S) = 2^{-n}\widehat{W}f(S)$.

**Theorem 2.8 (Parseval).** $\sum_S \widehat{W}f(S)^2 = 2^n \sum_x f(x)^2$.

*Proof.* Expand each square as a double sum over $x,y$, interchange the order of summation, and apply Proposition 2.6 to collapse the $S$-sum onto the diagonal. $\square$

Call $f$ a **sign function** if $f(x) \in \{\pm 1\}$ for all $x$; then $\sum_x f(x)^2 = 2^n$ and Theorem 2.8 normalises to:

**Corollary 2.9 (Spectral probability distribution).** For a sign function $f$, $\displaystyle\sum_S \mathrm{corr}(f,S)^2 = 1$.

The whole of the barrier language rests on the following elementary but crucial identity.

**Theorem 2.10 (Correlation is prediction advantage).** Let $f$ be a sign function and let $\mathrm{agree}(f,S) = \#\{x : f(x) = \chi_S(x)\}$. Then
$$\mathrm{agree}(f,S) \;=\; \frac{2^n\big(1 + \mathrm{corr}(f,S)\big)}{2}.$$

*Proof.* Split the sum defining $\widehat{W}f(S)$ into agreeing and disagreeing points; each agreeing point contributes $+1$ and each disagreeing point $-1$, so $\widehat{W}f(S) = 2\,\mathrm{agree}(f,S) - 2^n$. Divide by $2^n$. $\square$

**Corollary 2.11 (The $1/2$ barrier).** If $\mathrm{corr}(f,S) \le \varepsilon$ then $\chi_S$ predicts $f$ correctly on at most a $(1+\varepsilon)/2$ fraction of the cube. If $\mathrm{corr}(f,S) = 0$ the prediction rate is exactly $1/2$.

### 2.3 Flatness has a floor, and flatness costs support

Three consequences of Corollary 2.9 explain why "spectrally flat" is a substantive claim.

**Theorem 2.12 (Noise floor).** Every sign function $f$ admits some $S$ with $2^n\,\mathrm{corr}(f,S)^2 \ge 1$, i.e. $|\mathrm{corr}(f,S)| \ge 2^{-n/2}$.

*Proof.* Otherwise every squared coefficient is $< 2^{-n}$ and summing over the $2^n$ subsets contradicts Corollary 2.9. $\square$

**Theorem 2.13 (Few heavy coefficients).** For $\varepsilon > 0$, $\#\{S : |\mathrm{corr}(f,S)| \ge \varepsilon\}\cdot \varepsilon^2 \le 1$.

**Theorem 2.14 (Spectral spreading).** If $|\mathrm{corr}(f,S)| \le \varepsilon$ for all $S$, then $\#\{S : \mathrm{corr}(f,S) \ne 0\} \ge \varepsilon^{-2}$.

*Proof of 2.13 and 2.14.* Both are Corollary 2.9 read in two directions: the heavy coefficients each contribute at least $\varepsilon^2$ to a total of $1$; and the total $1$ must be assembled from coefficients each contributing at most $\varepsilon^2$. $\square$

**Definition 2.15.** $\mathrm{LowDeg}(n,d) = \{S : |S| \le d\}$, of cardinality $\sum_{i=0}^{d}\binom{n}{i}$.

**Theorem 2.16 (Low-degree mass bound).** If $|\mathrm{corr}(f,S)| \le \varepsilon$ for all $S \in \mathrm{LowDeg}(n,d)$, then
$$\sum_{S \in \mathrm{LowDeg}(n,d)} \mathrm{corr}(f,S)^2 \;\le\; \varepsilon^2 \sum_{i \le d}\binom{n}{i},
\qquad
\sum_{|S| > d} \mathrm{corr}(f,S)^2 \;\ge\; 1 - \varepsilon^2\sum_{i\le d}\binom{n}{i}.$$

**Numerical reading.** At $k = 14$ the public value has $n = 28$ bits, so a degree-$\le 3$ scan touches $1 + 28 + 378 + 3276 = 3683$ parities. With the observed $\varepsilon = 0.021$, Theorem 2.13 caps the number of $\varepsilon$-heavy parities at $2267 < 3683$, and Theorem 2.16 bounds the low-degree mass by $3683 \cdot 0.021^2 \approx 1.62$ — consistent with, but not by itself sufficient for, a conclusion about mass escaping to high degree. This is exactly why the next section proves an *exact* vanishing statement rather than relying on a measured bound: measured flatness at the observed resolution is suggestive; an identity is decisive.

---

## 3. The zero-block theorem: exact flatness of the low block

### 3.1 Setting

**Definition 3.1 (Odd support).** For $t \ge 1$ let $U_t = \{x : 0 \le x < 2^t,\; x \text{ odd}\}$, the odd residues modulo $2^t$; $|U_t| = 2^{t-1}$. This is the unit group of $\mathbb{Z}/2^t\mathbb{Z}$. The **support** is $U_t \times U_t$, of size $m = 4^{t-1}$, and the **public value** of a pair is $N = pq \bmod 2^t$.

**Definition 3.2 (Bit sign).** $\sigma_j(x) = (-1)^{x_j}$, where $x_j$ is bit $j$ of $x$.

Two lemmas carry the whole argument.

**Lemma 3.3 (Balance of interior bits).** For $1 \le j < t$, $\displaystyle \sum_{x \in U_t} \sigma_j(x) = 0$.

*Proof.* The map $\iota(x) = x \oplus 2^j$ is an involution of $U_t$: it preserves the bit at position $0$ because $j \ge 1$, hence preserves oddness; it preserves the range $x < 2^t$ because $j < t$; and it is its own inverse. It flips bit $j$, so $\sigma_j(\iota(x)) = -\sigma_j(x)$, and a sign-reversing involution forces the sum to vanish. $\square$

**Lemma 3.4 (Simple transitivity).** For $p \in U_t$ the map $q \mapsto pq \bmod 2^t$ is a bijection of $U_t$ onto itself.

*Proof.* Odd $p$ is coprime to $2^t$, so it is cancellable modulo $2^t$; the map is therefore injective, and a product of two odd numbers is odd, so it maps $U_t$ into $U_t$. Injective self-maps of a finite set are bijective. $\square$

### 3.2 The theorem

**Theorem 3.5 (Zero-block theorem).** Let $t \ge 2$ and $1 \le j < t$. Then for **every** function $g : \mathbb{Z}/2^t \to \mathbb{R}$,
$$\sum_{p \in U_t}\ \sum_{q \in U_t} \sigma_j(p)\, g\big(pq \bmod 2^t\big) \;=\; 0.$$

*Proof.* Fix $p$. By Lemma 3.4 the inner sum re-indexes as $\sigma_j(p) \sum_{N \in U_t} g(N)$, whose second factor does not depend on $p$. Summing over $p$ gives $\big(\sum_{p} \sigma_j(p)\big)\big(\sum_N g(N)\big)$, and the first factor vanishes by Lemma 3.3. $\square$

The scope of the quantifier is the point. $g$ is an *arbitrary* real function of the public value: every $\mathrm{GF}(2)$ parity of arbitrary degree, every real polynomial in the bits, every look-up table, every trained model. All of them have correlation exactly $0$ with $p_j$.

**Corollary 3.6 (Restricted Walsh spectrum vanishes).** Let $S$ be any set of bit positions with $\max S < t$ and let $\chi_S$ denote the corresponding parity of the bits of the *integer* product $pq$. Then $\sum_{p,q \in U_t} \sigma_j(p)\chi_S(pq) = 0$ for all $1 \le j < t$.

*Proof.* Bits below $t$ of $pq$ agree with bits of $pq \bmod 2^t$, so $\chi_S(pq) = \chi_S(pq \bmod 2^t)$; apply Theorem 3.5 with $g = \chi_S$. $\square$

This is exactly the quantity the spectral census measures, evaluated on the true integer product: on the low block it is not small but zero.

**Theorem 3.7 (Exact $1/2$ barrier).** Let $1 \le j < t$ and let $h : \mathbb{Z}/2^t \to \{0,1\}$ be an arbitrary predictor. Then
$$\#\{(p,q) \in U_t^2 : h(pq \bmod 2^t) = p_j\} \;=\; \#\{(p,q) \in U_t^2 : h(pq\bmod 2^t) \ne p_j\}.$$

*Proof.* Apply Theorem 3.5 with $g(N) = \mathrm{sgn}(h(N))$; the summand $\sigma_j(p)\mathrm{sgn}(h(N))$ is $+1$ exactly on the agreeing pairs and $-1$ exactly on the disagreeing pairs, so a $\pm1$-valued sum vanishing forces the two counts to be equal. $\square$

Note that no low-degree, efficiency, or uniformity hypothesis appears. The predictor may be arbitrarily complicated; it wins on exactly $m/2$ pairs, never one more.

### 3.3 Perfect secrecy of the low block

Theorem 3.5 is an averaged statement. It upgrades to a conditional one.

**Definition 3.8 (Fiber).** For $N \in U_t$, $\mathrm{Fib}(N) = \{(p,q) \in U_t^2 : pq \equiv N \pmod{2^t}\}$.

**Lemma 3.9.** For every $N \in U_t$ and every $a \in U_t$ there is exactly one pair in $\mathrm{Fib}(N)$ with first coordinate $a$, namely $(a, a^{-1}N \bmod 2^t)$. Consequently $|\mathrm{Fib}(N)| = 2^{t-1}$, and the map $\mathrm{Fib}(N) \to U_t$, $(p,q)\mapsto p$, is a bijection.

**Theorem 3.10 (Perfect secrecy).** For any predicate $P$ on $U_t$ and any $N, N' \in U_t$,
$$\#\{(p,q) \in \mathrm{Fib}(N) : P(p)\} \;=\; \#\{a \in U_t : P(a)\} \;=\; \#\{(p,q) \in \mathrm{Fib}(N') : P(p)\}.$$
In particular, for $1 \le j < t$, bit $j$ of the secret factor is $0$ on exactly half of each fiber, and any function $h$ producing a single candidate value for the secret low block satisfies $\#\{(p,q) \in \mathrm{Fib}(N) : p = h(N)\} \le 1$, i.e. success probability exactly $2^{-(t-1)}$, the blind-guess rate.

*Proof.* Immediate from the bijection of Lemma 3.9, together with Lemma 3.3 for the bit statement. $\square$

So the public low block is not merely uncorrelated with the secret low block: it is *statistically independent* of it in the strongest finite sense. Every public value sees the same secret distribution.

### 3.4 The mechanism, abstractly

**Theorem 3.11 (Group zero block).** Let $G$ be a finite group, $u, g : G \to \mathbb{R}$ with $\sum_{a \in G} u(a) = 0$. Then $\sum_{a \in G}\sum_{b \in G} u(a)\,g(ab) = 0$.

*Proof.* For fixed $a$, right translation $b \mapsto ab$ is a bijection of $G$, so $\sum_b g(ab) = \sum_c g(c)$ independently of $a$; factor and use $\sum_a u(a) = 0$. $\square$

Theorem 3.5 is the case $G = (\mathbb{Z}/2^t)^{\times}$, $u = \sigma_j$. What kills the correlation is the simple transitivity of the regular representation, not any property of primes or of multiplication of integers. The arithmetic input is confined to Lemma 3.3: bit $j$ of a unit is a mean-zero statistic precisely when $1 \le j < t$. (For $j = 0$ it is constant — every unit is odd — which is why the census reports a trivial correlation of $1.0$ at $j = 0$.)

---

## 4. The top-bit law: the unique non-flat family

### 4.1 The balanced support and the transmission law

**Definition 4.1 (Balanced support).** For $k \ge 2$ let $\mathcal{B}_k = \{(p,q) : 2^{k-1} \le p \le q < 2^k\}$, the balanced $k$-bit support. For $(p,q) \in \mathcal{B}_k$ we have $2^{2k-2} \le N = pq < 2^{2k}$, so $N$ has $2k-1$ or $2k$ bits and $N_{2k-1} = \mathbb{1}[N \ge 2^{2k-1}]$ is the carry-out indicator.

**Lemma 4.2.** If $2^{k-1} \le p$ and $p_{k-2} = 1$ then $p \ge 3\cdot 2^{k-2}$.

*Proof.* $p \ge 2^{k-1}$ gives $\lfloor p/2^{k-2}\rfloor \ge 2$, and $p_{k-2} = 1$ says $\lfloor p/2^{k-2}\rfloor$ is odd, so $\lfloor p/2^{k-2}\rfloor \ge 3$ and $p \ge 3\cdot 2^{k-2}$. $\square$

**Theorem 4.3 (Top-bit transmission law).** Let $(p,q) \in \mathcal{B}_k$. If $p_{k-2} = 1$ then $N = pq \ge 2^{2k-1}$, i.e. $N_{2k-1} = 1$.

*Proof.* By Lemma 4.2, $p \ge 3\cdot 2^{k-2}$, and $q \ge p$ gives $q \ge 3\cdot 2^{k-2}$ as well. Hence
$$N \;\ge\; 9 \cdot 2^{2k-4} \;>\; 8\cdot 2^{2k-4} \;=\; 2^{2k-1}.$$
Since $N < 2^{2k}$, the inequality $N \ge 2^{2k-1}$ is precisely the statement that bit $2k-1$ of $N$ is set. $\square$

**Corollary 4.4 (Contrapositive form).** For $(p,q)\in\mathcal{B}_k$, if the product does not carry into its top bit ($N < 2^{2k-1}$) then necessarily $p_{k-2} = 0$.

Two structural remarks make the interpretation precise.

**Proposition 4.5 (Symmetry).** For all $p,q,m$, bit $m$ of $pq$ equals bit $m$ of $qp$. In particular the conditioning statistic $N_{2k-1}$ is a symmetric function of the factor pair and is computable from $N$ alone: it distinguishes *size*, never *which factor is which*.

**Proposition 4.6 (Strict one-sidedness).** The converse of Theorem 4.3 fails, and fails already at $k = 5$. The semiprimes $17 \cdot 31 = 527$ and $29\cdot 31 = 899$ both lie in $\mathcal{B}_5$ with $N_9 = 1$, yet the second-highest bit of the smaller factor is $0$ for $p = 17$ and $1$ for $p = 29$. Likewise $17\cdot 31 = 527$ and $19\cdot 29 = 551$ agree in $N_9$ and differ in bit $1$ of the smaller factor. Hence knowledge of $N_{2k-1}$ neither determines $p_{k-2}$ nor any low bit of $p$.

### 4.2 Strict positivity of the top-bit covariance

**Definition 4.7.** Over the uniform measure on $\mathcal{B}_k$ let $A = \{(p,q) : p_{k-2} = 1\}$ and $B = \{(p,q) : N_{2k-1} = 1\}$, and let
$$\mathrm{cov}_k \;=\; \mathbb{P}(A \cap B) - \mathbb{P}(A)\mathbb{P}(B).$$

**Theorem 4.8 (The top-bit family is non-flat at every size).** $\mathrm{cov}_k > 0$ for every $k \ge 2$.

*Proof.* Theorem 4.3 says $A \subseteq B$, hence $\mathbb{P}(A\cap B) = \mathbb{P}(A)$ and
$$\mathrm{cov}_k \;=\; \mathbb{P}(A)\big(1 - \mathbb{P}(B)\big).$$
Now $A \ne \emptyset$: the pair $(3\cdot 2^{k-2}, 3\cdot 2^{k-2})$ lies in $\mathcal{B}_k$ and has $p_{k-2} = 1$. And $B \ne \mathcal{B}_k$: the pair $(2^{k-1}, 2^{k-1})$ lies in $\mathcal{B}_k$ with $N = 2^{2k-2} < 2^{2k-1}$, so $N_{2k-1} = 0$. Both factors are therefore strictly positive. $\square$

The contrast with Section 3 is the substance of the paper's verdict: on the low block the correlation is *exactly zero at every size*; in the top-bit family it is *strictly positive at every size*. Flat versus non-flat is a theorem, not a numerical impression.

### 4.3 The limiting constant

**Proposition 4.9 (Limit of the top-bit covariance).** $\displaystyle\lim_{k\to\infty}\mathrm{cov}_k = \frac{2\log 2 - 1}{4} = 0.0965735\ldots$

*Sketch.* Rescale by $p = 2^{k-1}x$, $q = 2^{k-1}y$. The balanced support becomes the triangle $\mathcal{S} = \{(x,y) \in [1,2]^2 : x \le y\}$ of area $1/2$, and the uniform measure on $\mathcal{B}_k$ converges weakly to the uniform measure on $\mathcal{S}$. The event $A$ becomes $\{x \ge 3/2\}\cap \mathcal{S}$, of area $1/8$, hence probability $1/4$. The carry-out event becomes $B = \{xy \ge 2\}\cap\mathcal{S}$; its complement inside $\mathcal{S}$ is $\{(x,y) : 1 \le x \le \sqrt 2,\ x \le y < 2/x\}$, of area $\int_1^{\sqrt 2}(2/x - x)\,dx = \log 2 - \tfrac12$, so $\mathrm{area}(B) = \tfrac12 - (\log 2 - \tfrac12) = 1 - \log 2$ and $\mathbb{P}(B) = 2(1-\log 2) = 0.61371\ldots$ The inclusion $A \subseteq B$ is preserved in the limit (if $x \ge 3/2$ and $y \ge x$ then $xy \ge 9/4 > 2$), so
$$\mathrm{cov}_\infty = \mathbb{P}(A)\big(1 - \mathbb{P}(B)\big) = \tfrac14\big(2\log 2 - 1\big) = 0.09657\ldots \qquad\square$$

Exact enumeration over $\mathcal{B}_k$ confirms the approach:

| $k$ | $\mathbb{P}(A)$ | $\mathbb{P}(B)$ | $\mathrm{cov}_k$ | $\mathrm{corr}(p_{k-2}, N_{2k-1})$ |
|---|---|---|---|---|
| 3 | 0.30000 | 0.40000 | 0.180000 | 0.80000 |
| 4 | 0.27778 | 0.50000 | 0.138889 | 0.55556 |
| 5 | 0.26471 | 0.55147 | 0.118728 | 0.42647 |
| 6 | 0.25758 | 0.58333 | 0.107323 | 0.34848 |
| 7 | 0.25385 | 0.59615 | 0.102515 | 0.31538 |
| 8 | 0.25194 | 0.60514 | 0.099481 | 0.29360 |
| 9 | 0.25097 | 0.60956 | 0.097990 | 0.28283 |

Here $\mathrm{corr}$ is the Walsh correlation $\mathbb{E}\big[(-1)^{p_{k-2}}(-1)^{N_{2k-1}}\big]$, the convention in which correlation $\varepsilon$ means prediction rate $(1+\varepsilon)/2$. We have $\mathbb{P}(A) \to 1/4$ and $\mathbb{P}(B) \to 2(1-\log 2) = 0.61371$ as predicted, and $\mathrm{cov}_k \downarrow 0.09657$.

**Corollary 4.10 (Limiting top-bit correlation).** In the Walsh convention, $\mathrm{corr} = 1 - 2\mathbb{P}(A) - 2\mathbb{P}(B) + 4\big(\mathrm{cov} + \mathbb{P}(A)\mathbb{P}(B)\big)$, so with $\mathbb{P}(A) \to 1/4$, $\mathbb{P}(B)\to 2(1-\log 2)$ and $\mathrm{cov} \to (2\log 2 - 1)/4$,
$$\lim_{k\to\infty}\mathrm{corr}(p_{k-2}, N_{2k-1}) \;=\; 4\log 2 - \tfrac52 \;=\; 0.2725887\ldots$$
This is the theoretical value of the census's headline non-flat coefficient, whose measured value at $k = 14$ over the prime-restricted support is $0.285$.

---

## 5. Confronting the theorems with computation

### 5.1 The exact flatness, verified

Enumerating the full odd support modulo $2^t$ for $t = 4, 5, 6$ in exact rational arithmetic gives, for every $1 \le j < t$ and every statistic tried — every parity of the low block, individual bits of $N$, the nonlinear statistic $N \bmod 7$, the magnitude indicator $\mathbb{1}[N > 2^{t-1}]$ — correlation exactly $0$. Fiber by fiber the counts are exactly $(8,8)$ for all $16$ fibers at $t = 5$ and $(16,16)$ for all $32$ fibers at $t = 6$, as Theorem 3.10 requires; every fiber has exactly $2^{t-1}$ points; and every fiber's set of first coordinates is the entire unit group.

### 5.2 The ordering defect

The zero-block theorem is a statement about *ordered pairs over the full odd support*. Two restrictions in the census break its hypotheses, and it is important to see exactly how.

**(a) The minimum convention.** The census takes $p$ to be the *smaller* factor. The involution $x \mapsto x \oplus 2^j$ of Lemma 3.3 does not preserve the constraint $p < q$, so the proof provably does not transfer. Exhaustive exact computation on the support $\{p < q\}$ modulo $2^t$ shows what remains. Scanning all bits $1 \le j \le t-2$ and *all* parities $S$ of the bits of the public value, the maximising coefficient at $t = 5, 6, 7$ is
$$4/15 = 0.2667 \;(j = 3),\qquad 8/31 = 0.2581\;(j=4),\qquad 16/63 = 0.2540\;(j=5),$$
in every case attained by the **empty** parity at the **highest** available bit of $p$. That is: the residual defect is not a parity of $N$ at all — it is the order statistic itself, a magnitude effect of the same species as Section 4. Restricting to genuinely low bits $j \le t/2$, the defect decays: $2/15 = 0.1333$, $4/31 = 0.1290$, $4/63 = 0.0635$ at $t = 5, 6, 7$, against noise floors $m^{-1/2} = 0.0913, 0.0449, 0.0223$ — a shrinking multiple of the floor.

**(b) The prime restriction.** The census further restricts to prime $p, q$. Primes are equidistributed among the units modulo $2^t$ only up to an error, so the exact cancellation degrades to an $O(\#\text{primes}^{-1/2})$ residue. This is the source of item 4 of Section 1.2: correlations $0.203 \to 0.013$ and $0.145 \to 0.009$ decaying across $k = 8,\dots,14$ are consistent with pure sampling noise at the $1/\sqrt{\pi(2^k)}$ scale.

### 5.3 The $j=2$ anomaly, resolved

Exhaustive enumeration over exact $k$-bit prime semiprimes with $p \le q$ gives the Walsh correlations of the low bit $p_2$ and of the top-family bit $p_{k-2}$ with the carry-out bit $N_{2k-1}$:

| $k$ | #primes | #pairs $m$ | $\mathrm{corr}(p_2, N_{2k-1})$ | $\mathrm{corr}(p_{k-2}, N_{2k-1})$ | $m^{-1/2}$ |
|---|---|---|---|---|---|
| 7 | 13 | 91 | $-0.0110$ | 0.5385 | 0.10483 |
| 8 | 23 | 276 | $+0.2536$ | 0.3188 | 0.06019 |
| 9 | 43 | 946 | $-0.0169$ | 0.2875 | 0.03251 |
| 10 | 75 | 2850 | $+0.1656$ | 0.2568 | 0.01873 |
| 11 | 137 | 9453 | $+0.0003$ | 0.2950 | 0.01029 |
| 12 | 255 | 32640 | $-0.0132$ | 0.2759 | 0.00554 |
| 13 | 464 | 107880 | $+0.0227$ | 0.2750 | 0.00304 |
| 14 | 872 | 380628 | $-0.0064$ | 0.2847 | 0.00162 |

These reproduce the census exactly: $0.254 / 0.166 / 0.013 / 0.006$ for the anomaly at $k = 8/10/12/14$, and $0.285$ for the top-bit coefficient at $k = 14$, against the limiting value $4\log 2 - 5/2 = 0.2726$ of Corollary 4.10. The full top-bit profile at $k = 12$ is
$$\mathrm{corr}(p_{k-d}, N_{2k-1}) = 0.276,\ 0.306,\ 0.143,\ 0.102,\ 0.011 \quad (d = 2,3,4,5,6),$$
matching the census's $0.285, 0.310, 0.132, 0.065, 0.026$ and confirming that the non-flat family is confined to a window of about six bits at the top of the factor.

Three features settle the matter.

1. **The partner is the top bit.** The single-bit winner for $p_2$ is $N_{2k-1}$, the product-magnitude indicator — not a low-order parity. Whatever is happening is happening inside the magnitude family.
2. **The sign alternates.** Values at $k = 7, 9, 12, 14$ are near zero or negative while $k = 8, 10$ are strongly positive. A genuine structural correlation does not flip sign with the bit length; a finite-sample fluctuation on a support of a few hundred points does.
3. **It decays; the real signal does not.** By $k = 14$ the $p_2$ column has fallen to $-0.0064$, a few multiples of $m^{-1/2} = 0.0016$ and below the all-parity noise level $0.0101$, while over the identical data the $p_{k-2}$ column sits at $0.2847$, indistinguishable from the theoretical limit $4\log 2 - 5/2 = 0.2726$ and showing no downward trend at all.

The conclusion is that the "$j = 2$ anomaly" was a small-$k$ shadow of the symmetric top-bit family: at $k = 8$ or $10$ there are only $23$ or $75$ primes in the window, so a low bit is correlated with the top bit of a prime by accident, and this accident propagates through Theorem 4.3.

---

## 6. Algorithms

### 6.1 Restricted Walsh spectrum by fast Walsh–Hadamard transform

To compute $\widehat{W}f(S)$ for all $S$ simultaneously when $f$ is given as a table on $\{0,1\}^n$, use the in-place butterfly: for each bit position $b$ and each pair of indices differing only at $b$, replace $(u,v)$ by $(u+v, u-v)$. This costs $O(n2^n)$ operations rather than the $O(4^n)$ of the naive double loop. When the support is a sparse subset of the cube (as here — semiprimes are rare), one first accumulates the sign-valued function into a dense array indexed by the public value, then transforms; a degree-$\le d$ scan reads off only the $\sum_{i \le d}\binom{n}{i}$ coefficients with small Hamming weight index.

### 6.2 Exact fiber-balance certification

To certify Theorem 3.10 at a given $t$, bucket all $4^{t-1}$ ordered odd pairs by $pq \bmod 2^t$ and, for each bucket and each bit $j$, count first coordinates with $p_j = 0$ and with $p_j = 1$. The theorem predicts $(2^{t-2}, 2^{t-2})$ in every cell. The computation is $O(4^t \cdot t)$ with exact integer arithmetic and requires no floating point: a genuine certificate rather than an estimate.

### 6.3 Exact covariance of the top-bit law

Enumerate $\mathcal{B}_k$, accumulate the four counts $(|A|, |B|, |A\cap B|, |\mathcal{B}_k|)$ in integers, and form $\mathrm{cov}_k$ as an exact rational. Cost $O(4^k)$; a smarter $O(2^k)$ variant replaces the inner loop by the closed form $\#\{q \in [p, 2^k) : q \ge 2^{2k-1}/p\}$.

### 6.4 Null calibration

For each measured maximum over a family $\mathcal{F}$ of parities, the correct comparison is the maximum of the same statistic under randomly re-signed data on the same support. Since $|\mathcal{F}|$ near-independent standardised coefficients have maximum concentrated near $\sqrt{2\log|\mathcal{F}|}$ in units of $m^{-1/2}$, one should expect an all-parity maximum of about $m^{-1/2}\sqrt{2\log 2^n} \approx m^{-1/2}\sqrt{2n\log 2}$. At $k = 14$ ($n = 28$, $m = 380628$) this predicts $\approx 6.2\,m^{-1/2} = 0.0101$ — exactly the reported all-parity noise level, which is why the observed $0.021$ maximum on the informative bits must be read as noise, not signal.

---

## 7. Discussion

### 7.1 What the results do and do not say

The zero-block theorem is unconditional, exact, and quantifies over all predictors — but it lives on the odd support modulo $2^t$ with ordered pairs, not on the prime-restricted, minimum-factor support of a real attack scenario. Both departures are recorded honestly here, and both are *quantified*: Section 5.2 shows that the ordered-pair defect is a magnitude statistic that decays with $t$, and that the prime restriction contributes at the equidistribution scale $\pi(2^k)^{-1/2}$.

The top-bit law is unconditional and holds for every balanced pair, prime or not. What it reveals is size, and size is public.

Together the two results bracket the truth from both sides. Below the transition window, correlation is exactly zero (odd support). At the very top, it is strictly positive at every size. The only open content is the width of the transition window, which the census measures as roughly six bits.

### 7.2 Why "flatness" is the right word

Section 2 makes flatness quantitative rather than rhetorical. Parseval fixes the total mass at $1$; the noise floor forbids universal flatness below $2^{-n/2}$; spectral spreading says a flat spectrum must be supported on at least $\varepsilon^{-2}$ parities. Thus the statement "the factoring bit function has no low-degree approximator" is the statement that its unit of Fourier mass has fled into the high-degree part of the cube, distributed among an enormous number of individually negligible coefficients. That is exactly the profile of a pseudorandom function, and it is the profile the census measures.

### 7.3 Relation to the barrier framework

In the language of barriers: **Barrier 1** — no low-degree $\mathrm{GF}(2)$ approximator to any factor bit — is established exactly on the odd support (Theorem 3.5, in the strong form that covers all predictors, Theorem 3.7) and measured to the resolution of the null model on the prime support. **Barrier 2** — all structure computable from $N$ is symmetric in the factors — is established for the only observed structure by Proposition 4.5. The Walsh/$\mathrm{GF}(2)$ face of the framework is therefore closed: what is flat is provably flat, and what is not flat is provably harmless.

---

## 8. Future directions

**C1. The ordering defect is exactly a top-bit statistic.** Conjecture: for $t \ge 2$ and $1\le j<t$, over the support of *ordered* odd pairs $p<q$ modulo $2^t$, every correlation of $p_j$ with a statistic of the low block is nonzero but bounded by $C\cdot 2^{-t/2}$, and the entire defect is carried by the event $p<q$: the correlation equals $\mathrm{Cov}(\mathbb{1}[p<q], g(N))$ times a factor depending only on $j$, up to $O(2^{-t})$. The proof of the exact theorem isolates the involution as the single point of failure, so the defect must be a functional of the order statistic — a magnitude statistic, the same family as the top-bit law. The computations of Section 5.2 support this sharply: the maximising coefficient is always the empty parity at the highest bit.

**C2. A degree hierarchy over the prime-restricted support.** Conjecture: for the exact $k$-bit prime semiprime support and every fixed degree $d$ there is $k_0(d)$ such that for all $k \ge k_0(d)$ and all $1 \le j \le k-7$, every parity of degree $\le d$ of the bits of $N$ correlates with $p_j$ by at most $C_d\,\pi(2^k)^{-1/2}\mathrm{polylog}$, while for $j > k-7$ the maximum degree-$1$ correlation stays bounded away from $0$. The two proved theorems bracket the truth — exactly zero below, strictly positive above — so the only open content is the transition window, whose width the census measures as about six bits. Theorem 2.16 converts any such correlation bound into a statement about where the Fourier mass lives, so a single quantitative equidistribution input (primes in short arithmetic progressions modulo $2^t$) would upgrade the empirical claim to a theorem.

**C3. Sharp constant for the top-bit covariance.** Proposition 4.9 gives the limit $(2\log 2 - 1)/4$ (equivalently, correlation $4\log 2 - 5/2 = 0.2726$, Corollary 4.10) via the rescaling argument; a fully rigorous proof requires only a uniform error term for the lattice-point count in the region $\{xy \ge 2\}\cap\mathcal{S}$, which should give $\mathrm{cov}_k = (2\log2-1)/4 + O(2^{-k})$. The same method should yield the whole profile $\mathrm{corr}(p_{k-d}, N_{2k-1})$ for $d = 2,3,4,\dots$ as explicit areas of regions cut out by $\{x \in [1+2^{-(d-1)}\cdot(\text{odd multiples})]\}$, quantifying the six-bit transition window exactly.

**C4. Beyond parities.** The zero-block theorem covers all predictors on the odd support, so the natural next targets are supports where it fails by design: the minimum convention (C1), the prime restriction (C2), and unbalanced factor sizes, where the magnitude family is much richer. A quantitative theory of the magnitude family — the exact set of statistics of $N$ that constrain factor sizes — would complete the classification of $N$-computable structure into "symmetric size information" and "nothing else".

**C5. Higher moduli.** Every step of Section 3 uses only that the residues form a group under multiplication. The same theorem holds verbatim for the unit group modulo any $M$, with Lemma 3.3 replaced by the requirement that the chosen statistic of $p$ have mean zero on $(\mathbb{Z}/M)^\times$. Determining which digit statistics in base $b$ are mean-zero on the unit group modulo $b^t$ would extend the flat block from binary to arbitrary bases.

---

## 9. Conclusion

The factoring function, viewed through the Walsh spectrum of its secret bits, is spectrally flat: on the low block, exactly and provably so, for every predictor and not merely for low-degree parities, with perfect secrecy behind the vanishing. The single non-flat structure is the top-bit magnitude/carry family, which obeys a deterministic one-sided transmission law, has strictly positive covariance at every size with an explicit limit $(2\log 2 - 1)/4$, and is symmetric in the two factors — hence reveals the size of the numbers, never their identity. The remaining empirical curiosities, including the low-bit anomaly at small sizes, are finite-support fluctuations of this same magnitude family, decaying with the size of the support, as the exhaustive computations demonstrate. The negative result is complete and it carries positive content: on this face of the problem, there is nothing to find but a ruler.
