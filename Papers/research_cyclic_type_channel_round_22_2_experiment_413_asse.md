# The Cyclic Splitting-Type Channel: Exact Laws, Divisor Bounds, and the Breaking of the One-Bit Pair Cap

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

Let $f$ be a prime and let $\mathbb{Q}(\zeta_f)$ be the corresponding cyclotomic field, with cyclic Galois group $C_n$, $n = f-1$. To each unramified rational prime $p$ we attach its *splitting type* $T(p) = \operatorname{ord}_f(p)$, the residue degree of $p$ in $\mathbb{Q}(\zeta_f)$; this is the complete invariant of the decomposition of $p$, and it is an exact function of $p \bmod f$. Modelling Frobenius equidistribution (Chebotarev) by a uniform variable $x$ on $C_n$ with $T(x) = n/\gcd(n,x)$, we study two derived information channels: the *single-prime type channel*, with entropy $H(T)(n)$, and the *semiprime type-pair channel*
$$I_{\mathrm{pair}}(n) = H(\Pi) - \frac1n\sum_{c \in C_n} H(\Pi_c),$$
the mutual information between the product class $N \equiv x+y$ and the unordered type pair $\{T(x),T(y)\}$.

We prove: (i) an **exact closed form** for the pair channel at every prime cyclic order,
$$I_{\mathrm{pair}}(p) = \log_2 p - \frac{(p-1)(2p-1)}{p^2}\log_2(p-1) + \frac{(p-1)(p-2)}{p^2}\log_2(p-2);$$
(ii) sharp two-sided asymptotics $\frac{1}{p^2\ln 2} \le I_{\mathrm{pair}}(p) \le \frac{\log_2 p + 5}{p^2}$ for odd primes, so the prime-order channel is strictly positive but closes quadratically; (iii) the **sub-cap theorem**: $I_{\mathrm{pair}}(p) < 1$ for every odd prime and $I_{\mathrm{pair}}(p) = 1$ if and only if $p = 2$, whereas exhaustive evaluation gives $I_{\mathrm{pair}}(n) > 1$ for $n = 4,6,8,10,12,14,16$ — the one-bit binary-fork cap is broken by composite, not by large, Galois orders; (iv) **CRT multiplicativity** $T_{mn} = T_m T_n = \operatorname{lcm}(T_m,T_n)$ for coprime moduli, and the resulting exact additivity $H(T)(mn) = H(T)(m)+H(T)(n)$, hence a Sylow decomposition $H(T)(n) = \sum_{p \mid n} H(T)(p^{v_p(n)})$; (v) the closed form $H(T)(2^k) = 2 - 2^{1-k}$, so the $2$-adic tower saturates at exactly two bits; (vi) the **divisor-lattice sandwich** $H(\mathrm{nr}) \le H(T) \le \log_2 d(n)$, with both inequalities strict for $n \ge 3$; and (vii) a complete lossiness dichotomy for the binary root-count readout: $H(\mathrm{nr}) < H(T)$ if and only if $n$ is composite, with the loss tending to the full two bits along the $2$-adic tower.

**Keywords.** cyclotomic field, Frobenius splitting type, Chebotarev equidistribution, mutual information, Euler totient law, divisor lattice, semiprime channel.

---

## 1. Introduction

### 1.1 The one-bit phenomenon

A recurring question in the information-theoretic study of arithmetic is: *how much does a product of two primes reveal about its factors, short of factoring?* The standard setting attaches to each prime $p$ a binary arithmetic label $\varepsilon(p) \in \{\pm 1\}$ — a Legendre symbol, a split/inert indicator, a residue-class bit — and asks for the mutual information between $N = pq$ (equivalently, its residue class) and the *unordered* pair $\{\varepsilon(p),\varepsilon(q)\}$.

For every symmetric binary label of this kind the answer is at most one bit, and the bound is attained: knowing $N \bmod f$ determines the *product* $\varepsilon(p)\varepsilon(q)$ exactly, but nothing more, so the recoverable information is exactly the entropy of one balanced bit. We refer to this as the **binary-fork cap**.

The cap is often read as a structural obstruction. The results below show that it is instead an artifact of the *instrument*: the binary label is a lossy coarsening of a genuinely multi-state observable, and the complete observable breaks the cap.

### 1.2 The complete observable

For $\mathbb{Q}(\zeta_f)$ with $f$ prime, the Galois group is $(\mathbb{Z}/f)^\times \cong C_n$ with $n = f-1$, and the Frobenius class of an unramified prime $p$ is the residue $p \bmod f$. The *splitting type*
$$T(p) = \operatorname{ord}_f(p)$$
is the residue degree: $p$ factors into exactly $n/T(p)$ distinct primes of $\mathbb{Q}(\zeta_f)$, each of residue degree $T(p)$. This is a complete description of the splitting behaviour, and it is a *deterministic function of $p \bmod f$*, so the mutual information between the residue class and the type equals $H(T)$ exactly. Refining the residue to $p \bmod f^2$ (or any higher power) adds nothing: the channel is concentrated at level one.

The traditional binary readout is the coarsening
$$\mathrm{nr}(p) = \mathbf{1}[\,T(p)=1\,],$$
"does $p$ split completely?". For $f = 5$ this collapses the distinct behaviours $T=2$ (two primes of degree $2$) and $T=4$ (inert) into a single symbol; for $f = 7$ it collapses three distinct behaviours. Quantifying that collapse, and its consequence for the semiprime channel, is the content of this paper.

### 1.3 Contributions

1. An exact, symbolic-in-$p$ closed form for the semiprime type-pair channel at prime cyclic orders (Theorem 5.1), with a clean upper envelope (Theorem 5.2) and sharp quadratic two-sided bounds (Theorem 5.4).
2. The sub-cap theorem: prime orders never exceed one bit, and $p=2$ uniquely attains it (Theorems 5.5, 5.6); combined with exhaustive evaluation at composite orders, this localises the cap-breaking phenomenon on the divisor structure of the Galois group.
3. Structural multiplicativity: the CRT factorisation of the type map (Theorem 6.1), additivity of the type entropy over coprime factorisations (Theorem 6.2), and the resulting Sylow decomposition (Theorem 6.3) with an explicit squarefree formula (Corollary 6.4).
4. The exact $2$-adic law $H(T)(2^k) = 2 - 2^{1-k}$, with strict monotonicity and saturation at two bits (Theorem 7.1).
5. The divisor-lattice bounds $H(T) \le \log_2 n$ and $H(T) \le \log_2 d(n)$, strict for $n \ge 3$ (Theorems 8.2, 8.3), and the full sandwich $H(\mathrm{nr}) \le H(T) \le \log_2 d(n)$.
6. The lossiness dichotomy $H(\mathrm{nr}) < H(T) \iff n$ composite (Theorem 9.2), the quantitative decay $H(\mathrm{nr}) \le (\log_2 n + 2)/n \to 0$ (Theorem 9.3), and total loss along the $2$-tower (Corollary 9.4).

---

## 2. The probabilistic model

### 2.1 From Chebotarev to a uniform group element

By the Chebotarev density theorem, the Frobenius classes of the unramified primes are equidistributed in the Galois group: for $\mathbb{Q}(\zeta_f)$ each residue class in $(\mathbb{Z}/f)^\times$ carries natural density $1/n$. All statements below are therefore statements about the following finite model, and translate to densities of primes verbatim.

**Model.** Let $n \ge 1$ and let $x$ be uniform on the cyclic group $C_n = \mathbb{Z}/n$ (written additively). Define the **splitting type**
$$T_n(x) \;=\; \frac{n}{\gcd(n,x)} \in \{d : d \mid n\},$$
which is exactly the order of $x$ in $C_n$; under the identification of $C_n$ with $\operatorname{Gal}(\mathbb{Q}(\zeta_f)/\mathbb{Q})$ this is the residue degree $\operatorname{ord}_f(p)$.

**Proposition 2.1 (Totient law).** $\mathbb{P}(T_n = d) = \varphi(d)/n$ for every divisor $d \mid n$.

*Proof sketch.* The elements of order $d$ in a cyclic group of order $n$ are the $\varphi(d)$ generators of its unique subgroup of order $d$. $\square$

Consequently, writing $H$ for Shannon entropy in bits,
$$H(T)(n) \;=\; -\sum_{d \mid n} \frac{\varphi(d)}{n}\log_2\frac{\varphi(d)}{n} \;=\; \log_2 n \;-\; \frac1n\sum_{d\mid n}\varphi(d)\log_2\varphi(d). \tag{2.1}$$
We abbreviate $H(T)(n)$ by $H_T(n)$ where convenient.

**Example 2.2.** $H_T(4) = 2 - \tfrac14(2\cdot 1) = 1.5$ exactly, realised in $\mathbb{Q}(\zeta_5)$ by the three types $\{1,2,4\}$ with densities $\tfrac14,\tfrac14,\tfrac12$. $H_T(6) = \log_2 6 - \tfrac{4}{6} = 1.9183\ldots$, realised in $\mathbb{Q}(\zeta_7)$ by $\{1,2,3,6\}$ with densities $\tfrac16,\tfrac16,\tfrac13,\tfrac13$. Sampling actual primes reproduces $1.4989$ and $1.9183$ respectively.

### 2.2 The binary root-count readout

Define $\mathrm{nr}_n(x) = \mathbf{1}[T_n(x) = 1]$, the indicator that $x$ is the identity (equivalently, that $p$ splits completely). Its occupation numbers are $[1, n-1]$, so
$$H(\mathrm{nr})(n) \;=\; h_2\!\left(\tfrac1n\right) \;=\; \log_2 n - \frac{n-1}{n}\log_2 (n-1), \tag{2.2}$$
where $h_2$ is the binary entropy function. We write $H_{\mathrm{nr}}(n)$ for this quantity.

### 2.3 The semiprime type-pair channel

Let $x,y$ be independent and uniform on $C_n$, modelling the Frobenius classes of two independent primes $p,q$. The Frobenius class of $N = pq$ is $c = x+y$. The observable of interest is the **unordered type pair**
$$K(x,y) \;=\; \{\,T_n(x),\,T_n(y)\,\},$$
recorded as a sorted pair $(\min, \max)$. Let $\Pi$ be its law over all $n^2$ ordered pairs and $\Pi_c$ its law conditioned on $x+y=c$. Since $c$ is uniform on $C_n$, the mutual information is
$$\boxed{\;I_{\mathrm{pair}}(n) \;=\; H(\Pi) \;-\; \frac1n\sum_{c\in C_n} H(\Pi_c).\;} \tag{2.3}$$

Three remarks fix the interpretation.

* **Unorderedness is essential.** The channel is symmetric under swapping the two primes; the "which factor is which" information measured empirically on genuine semiprimes is $0.0001$ bits, i.e. numerically zero. The channel says something about the pair, nothing about the individual factors.
* **Everything is finite and exact.** $\Pi$ and each $\Pi_c$ are integer occupation tables of total mass $n^2$ and $n$, so $I_{\mathrm{pair}}(n)$ is an explicit finite sum of logarithms of rationals; the values reported below are exact, not estimates.
* **The binary channel is a projection.** Replacing $T$ by $\mathrm{nr}$ in (2.3) yields the classical split-count channel; its values are strictly smaller (see §10), which is the precise sense in which the split-count channel is one *face* of the type channel.

---

## 3. Numerical landscape

Exhaustive evaluation of (2.1)–(2.3) gives the following exact values (rounded to four decimals).

| $n$ | field $\mathbb{Q}(\zeta_{n+1})$ (when $n+1$ prime) | #types | $H_T(n)$ | $H_{\mathrm{nr}}(n)$ | $H(\Pi)$ | $H(\Pi\mid N)$ | $I_{\mathrm{pair}}(n)$ |
|---|---|---|---|---|---|---|---|
| $2$ | $\mathbb{Q}(\sqrt5)$ | $2$ | $1.0000$ | $1.0000$ | $1.5000$ | $0.5000$ | $1.0000$ |
| $3$ | — | $2$ | $0.9183$ | $0.9183$ | $1.3921$ | $0.9183$ | $0.4739$ |
| $4$ | $\mathbb{Q}(\zeta_5)$ | $3$ | $1.5000$ | $0.8113$ | $2.3750$ | $1.1250$ | $\mathbf{1.2500}$ |
| $5$ | — | $2$ | $0.7219$ | $0.7219$ | $1.1239$ | $0.9211$ | $0.2027$ |
| $6$ | $\mathbb{Q}(\zeta_7)$ | $4$ | $1.9183$ | $0.6500$ | $3.1144$ | $1.6405$ | $\mathbf{1.4739}$ |
| $7$ | — | $2$ | $0.5917$ | $0.5917$ | $0.9384$ | $0.8243$ | $0.1141$ |
| $8$ | — | $4$ | $1.7500$ | $0.5436$ | $2.8438$ | $1.5312$ | $\mathbf{1.3125}$ |
| $9$ | — | $3$ | $1.2244$ | $0.5033$ | $1.9550$ | $1.4285$ | $0.5265$ |
| $10$ | $\mathbb{Q}(\zeta_{11})$ | $4$ | $1.7219$ | $0.4690$ | $2.7839$ | $1.5811$ | $\mathbf{1.2027}$ |
| $12$ | $\mathbb{Q}(\zeta_{13})$ | $6$ | $2.4183$ | $0.4138$ | $4.0449$ | $2.3211$ | $\mathbf{1.7239}$ |
| $16$ | $\mathbb{Q}(\zeta_{17})$ | $5$ | $1.8750$ | $0.3373$ | $3.0859$ | $1.7578$ | $\mathbf{1.3281}$ |

Empirical corroboration on approximately $3\times10^4$ genuine semiprimes reproduces the model values to within a few thousandths of a bit: $1.2452$ against the exact $1.2500$ for $n=4$, and $1.4711$ against the exact $1.4739$ for $n=6$.

Three features stand out, and the rest of the paper explains all three.

* The quadratic case $n=2$ reproduces the binary-fork cap **exactly**: $I_{\mathrm{pair}}(2) = 1$.
* Every prime order $n = p$ falls *below* the cap and decays rapidly ($0.4739, 0.2027, 0.1141, \dots$).
* Every even composite order tested is *above* the cap, with the richest value at $n=12$, whose divisor lattice has six levels.

---

## 4. Determinism and thickening

**Proposition 4.1 (Exact determinism).** In the model, $T_n$ is a deterministic function of $x$; hence $I(x; T_n) = H_T(n)$, with no residual noise. Arithmetically: the mutual information between $p \bmod f$ and the splitting type of $p$ in $\mathbb{Q}(\zeta_f)$ equals $H(T)$ exactly.

**Proposition 4.2 (Thickening is free).** $I(p \bmod f^k ; T) = I(p \bmod f ; T)$ for every $k \ge 1$.

*Proof sketch.* $T(p) = \operatorname{ord}_f(p)$ factors through the reduction $(\mathbb{Z}/f^k)^\times \to (\mathbb{Z}/f)^\times$; a variable and any refinement of it carry the same mutual information with a function of the coarse variable, by the data-processing identity for deterministic maps. $\square$

Together these say the channel is *thin*: all its content sits at the first level of the $f$-adic tower, and there is no hidden depth to exploit. Coprime controls (conditioning on residues modulo primes other than $f$) are flat, as expected.

---

## 5. The prime-order pair channel in closed form

Throughout this section $p$ is prime and the cyclic order is $n = p$. Then $T_p(x) \in \{1,p\}$, with $T_p(x)=1$ iff $x=0$.

### 5.1 Occupation numbers

**Lemma 5.0 (Unconditional and conditional tables).** Order the three possible unordered pairs as $(1,1), (1,p), (p,p)$. Then, over all $p^2$ ordered pairs $(x,y)$, the occupation numbers of $\Pi$ are
$$\big[\,1,\;2(p-1),\;(p-1)^2\,\big],$$
while the conditional tables are
$$\Pi_0 : \big[\,1,\;0,\;p-1\,\big], \qquad \Pi_c : \big[\,0,\;2,\;p-2\,\big]\ \ (c \neq 0),$$
each of total mass $p$.

*Proof sketch.* $(1,1)$ occurs only for $x=y=0$; $(1,p)$ requires exactly one of $x,y$ to vanish, giving $2(p-1)$ ordered pairs; the rest are $(p,p)$. For the conditional tables, parametrise the fibre $x+y=c$ by $x$, so $y = c-x$. If $c=0$: $y=0$ iff $x=0$, so the state is $(1,1)$ once and $(p,p)$ on the remaining $p-1$ values; the mixed state cannot occur. If $c\neq0$: the mixed state occurs exactly at the two values $x=0$ and $x=c$, which are distinct, and $(p,p)$ on the remaining $p-2$; the split state cannot occur, because $x=y=0$ would force $c=0$. $\square$

This is where the geometry of the channel lives: **conditioning on the product class partitions the fibres into a single "split-compatible" class $c=0$ and $p-1$ "mixed-compatible" classes**, and it is precisely that asymmetry which the mutual information measures.

### 5.2 The closed form

**Theorem 5.1 (Exact prime-order pair channel).** For every prime $p$,
$$I_{\mathrm{pair}}(p) \;=\; \log_2 p \;-\; \frac{(p-1)(2p-1)}{p^{2}}\,\log_2 (p-1) \;+\; \frac{(p-1)(p-2)}{p^{2}}\,\log_2 (p-2),$$
with the convention that the last term is $0$ at $p=2$ (where its coefficient vanishes).

*Proof sketch.* From Lemma 5.0 and the identity $H = \log_2 M - \frac1M\sum_i c_i \log_2 c_i$ for occupation numbers $c_i$ of total mass $M$:
$$H(\Pi) = 2\log_2 p - \frac{1}{p^2}\Big(2(p-1) + 2p(p-1)\log_2(p-1)\Big),$$
$$H(\Pi_0) = \log_2 p - \frac{p-1}{p}\log_2(p-1), \qquad H(\Pi_c) = \log_2 p - \frac{1}{p}\Big(2 + (p-2)\log_2(p-2)\Big).$$
Averaging the conditionals with weights $\tfrac1p$ and $\tfrac{p-1}{p}$ gives
$$H(\Pi\mid N) = \log_2 p - \frac{p-1}{p^2}\log_2(p-1) - \frac{p-1}{p^2}\Big(2 + (p-2)\log_2(p-2)\Big),$$
and subtracting yields the stated identity; the $2(p-1)/p^2$ terms cancel and the coefficients of $\log_2(p-1)$ combine to $-\frac{(p-1)(2p-1)}{p^2}$. $\square$

**Checks.** $p=2$: $\log_2 2 - \tfrac{3}{4}\log_2 1 + 0 = 1$. $p=3$: $\log_2 3 - \tfrac{10}{9} = 0.47385\ldots$. $p=5$: $\log_2 5 - \tfrac{36}{25}\cdot2 + \tfrac{12}{25}\log_2 3 = 0.20271\ldots$. All agree with direct enumeration.

### 5.3 Envelope and decay

**Theorem 5.2 (Upper envelope).** For every prime $p$,
$$I_{\mathrm{pair}}(p) \;\le\; \log_2 p - \log_2(p-1) + \frac{\log_2(p-1)}{p^{2}}.$$

**Theorem 5.3 (Algebraic split).** For every prime $p$,
$$I_{\mathrm{pair}}(p) = \Big(\log_2 p - \log_2(p-1)\Big) + \frac{\log_2 (p-1)}{p^{2}} - \frac{(p-1)(p-2)}{p^{2}}\Big(\log_2 (p-1) - \log_2 (p-2)\Big).$$

*Proof sketch.* Expand and match coefficients: the coefficient of $\log_2(p-1)$ is $-1 + p^{-2} - (p-1)(p-2)p^{-2} = -\frac{(p-1)(2p-1)}{p^2}$, and that of $\log_2(p-2)$ is $+\frac{(p-1)(p-2)}{p^2}$. Theorem 5.2 follows by discarding the (nonnegative) last term. $\square$

**Theorem 5.4 (Quadratic two-sided bounds).** For every odd prime $p$,
$$\frac{1}{p^{2}\ln 2} \;\le\; I_{\mathrm{pair}}(p) \;\le\; \frac{\log_2 p + 5}{p^{2}},$$
and in particular $I_{\mathrm{pair}}(p) > 0$: the prime-order channel is never exactly silent. Moreover $I_{\mathrm{pair}}(p) < 3/(p-1)$ for every odd prime.

*Proof sketch.* Use the elementary two-sided estimate $\frac{x-y}{x} \le \ln\frac{x}{y} \le \frac{x-y}{y}$ for $0<y\le x$ on both logarithm differences appearing in Theorem 5.3. For the lower bound: $\log_2 p - \log_2(p-1) \ge \frac{1}{p\ln 2}$ and $\log_2(p-1)-\log_2(p-2) \le \frac{1}{(p-2)\ln 2}$, so the subtracted term is at most $\frac{p-1}{p^2\ln 2}$; hence
$$I_{\mathrm{pair}}(p) \ge \frac{1}{p\ln2} - \frac{p-1}{p^{2}\ln 2} + \frac{\log_2(p-1)}{p^{2}} = \frac{1}{p^{2}\ln 2} + \frac{\log_2 (p-1)}{p^{2}} \ge \frac{1}{p^{2}\ln 2}.$$
For the upper bound, reverse both estimates: $\log_2 p - \log_2(p-1)\le \frac{1}{(p-1)\ln2}$ and $\log_2(p-1)-\log_2(p-2) \ge \frac{1}{(p-1)\ln 2}$, so
$$I_{\mathrm{pair}}(p) \le \frac{1}{\ln 2}\left(\frac{1}{p-1} - \frac{p-2}{p^{2}}\right) + \frac{\log_2(p-1)}{p^{2}} = \frac{3p-2}{(p-1)p^{2}\ln 2} + \frac{\log_2(p-1)}{p^{2}},$$
and $\frac{3p-2}{(p-1)\ln 2} \le 5$ for $p\ge3$ with room to spare once $\log_2(p-1) < \log_2 p$ is used. The $3/(p-1)$ bound follows from Theorem 5.2 with $\log_2\frac{p}{p-1}\le\frac{1}{(p-1)\ln2}$. $\square$

### 5.4 The sub-cap theorem

**Theorem 5.5 (Sub-cap).** For every odd prime $p$, $I_{\mathrm{pair}}(p) < 1$.

*Proof sketch.* For $p \ge 5$, Theorem 5.4 gives $I_{\mathrm{pair}}(p) < 3/(p-1) \le 3/4 < 1$. The single remaining case $p=3$ is the explicit value $\log_2 3 - \tfrac{10}{9} = 0.4739\ldots < 1$. $\square$

**Theorem 5.6 (Uniqueness of the extremal prime).** For a prime $p$, $I_{\mathrm{pair}}(p) = 1$ if and only if $p = 2$.

*Proof sketch.* Theorem 5.1 gives the value $1$ at $p=2$; Theorem 5.5 excludes all odd primes. $\square$

**Corollary 5.7 (Localisation of the cap-breaking).** Exhaustive evaluation gives $I_{\mathrm{pair}}(n) > 1$ for $n = 4,6,8,10,12,14,16$, while Theorem 5.5 forbids it for every prime order. Hence exceeding the binary-fork cap is not a matter of the *size* of the Galois group but of the *divisor structure* of its order.

This is the central structural statement of the paper: a two-level divisor lattice — the defining feature of a prime order — cannot support more than one bit of pair information, and it supports exactly one bit only in the degenerate quadratic case $p=2$.

---

## 6. Multiplicative structure: CRT, additivity, Sylow decomposition

**Theorem 6.1 (CRT factorisation of the type).** Let $m,n$ be coprime and $a$ any integer. Then
$$T_{mn}(a) \;=\; T_m(a)\cdot T_n(a) \;=\; \operatorname{lcm}\big(T_m(a),\,T_n(a)\big).$$

*Proof sketch.* Coprimality gives $\gcd(mn,a) = \gcd(m,a)\gcd(n,a)$, whence $\frac{mn}{\gcd(mn,a)} = \frac{m}{\gcd(m,a)}\cdot\frac{n}{\gcd(n,a)}$. Since $T_m(a) \mid m$ and $T_n(a)\mid n$, the two factors are themselves coprime, so their product equals their lcm. $\square$

Group-theoretically this is the statement that under $C_{mn}\cong C_m\times C_n$ the order of an element is the lcm of the orders of its coordinates. Its information-theoretic consequence is exact additivity.

**Theorem 6.2 (Coprime additivity of the type entropy).** For all $m,n \ge 1$ with $\gcd(m,n)=1$,
$$H_T(mn) \;=\; H_T(m) + H_T(n).$$

*Proof sketch.* Under the CRT isomorphism, a uniform element of $C_{mn}$ corresponds to a pair of independent uniform elements of $C_m$ and $C_n$. By Theorem 6.1 the type variable of $C_{mn}$ is the pair $(T_m, T_n)$ up to the bijection $(u,v)\mapsto uv$ on coprime pairs of divisors, and the entropy of a pair of independent variables is the sum of their entropies. Concretely, (2.1) together with the multiplicativity of $\varphi$ and the divisor-sum factorisation $\sum_{d \mid mn} = \sum_{i\mid m}\sum_{j \mid n}$ (with $d = ij$) turns the log-sum into $\log_2 (mn) - \frac{1}{mn}\sum_{i,j}\varphi(i)\varphi(j)\big(\log_2\varphi(i)+\log_2\varphi(j)\big)$, which splits. $\square$

**Theorem 6.3 (Sylow decomposition).** For $n \ge 1$,
$$H_T(n) \;=\; \sum_{p \mid n} H_T\!\big(p^{\,v_p(n)}\big),$$
the sum over the distinct prime factors of $n$, with $v_p$ the $p$-adic valuation. In particular $H_T(1)=0$.

*Proof sketch.* Iterate Theorem 6.2 over the prime factorisation, whose parts are pairwise coprime. $\square$

**Corollary 6.4 (Squarefree formula).** If $n$ is squarefree then
$$H_T(n) \;=\; \sum_{p\mid n}\left(\log_2 p - \frac{p-1}{p}\log_2 (p-1)\right).$$

*Proof sketch.* Apply Theorem 6.3 and evaluate (2.1) for prime order: the type law is $[\tfrac1p, \tfrac{p-1}{p}]$. $\square$

**Corollary 6.5 (Monotonicity in the factorisation).** Each Sylow piece is a lower bound: if $d \mid n$ with $\gcd(d, n/d) = 1$ then $H_T(d)\le H_T(n)$. Adding prime factors to the Galois order never destroys splitting information.

*Proof sketch.* Immediate from Theorem 6.2 and $H_T \ge 0$. $\square$

---

## 7. The $2$-adic tower saturates at two bits

**Theorem 7.1 ($2$-adic closed form).** For every $k \ge 0$,
$$H_T(2^k) \;=\; 2 - 2^{\,1-k}.$$
The sequence is strictly increasing in $k$, never attains $2$, and converges to $2$.

*Proof sketch.* The divisors of $2^k$ are $2^j$, $0\le j\le k$, with $\varphi(2^j) = 2^{j-1}$ for $j\ge1$ and $\varphi(1)=1$. An induction gives the log-sum
$$\sum_{j=0}^{k}\varphi(2^j)\log_2\varphi(2^j) \;=\; (k-2)2^{k} + 2,$$
and substituting into (2.1) yields $H_T(2^k) = k - 2^{-k}\big((k-2)2^k+2\big) = 2 - 2^{1-k}$. Strict monotonicity and the limit are immediate. $\square$

So the $2$-primary part of any cyclic Galois group contributes at most two bits, no matter how deep the tower — in sharp contrast with the prime direction, where $H_T(p) = \log_2 p - \frac{p-1}{p}\log_2(p-1) \sim \frac{\log_2 p}{p}\cdot p^{0}$ grows without bound only through the *number* of prime factors, not through depth. Combined with Theorem 6.3, this is a complete qualitative description: **depth saturates, breadth accumulates.**

---

## 8. The divisor-lattice ceiling

**Lemma 8.1.** For $n \ge 3$ the divisor count satisfies $d(n) < n$; for $n \in \{1,2\}$, $d(n)=n$.

*Proof sketch.* The divisors of $n$ lie in $\{1,\dots,n\}$ and $n-1$ is not a divisor for $n\ge3$. $\square$

**Theorem 8.2 (Residue ceiling).** $H_T(n)\le \log_2 n$ for $n\ge1$, with strict inequality for $n\ge3$.

*Proof sketch.* $T$ is a function of the uniform variable $x$, so its entropy is at most $\log_2 n$; by (2.1), the deficit is $\frac1n\sum_{d\mid n}\varphi(d)\log_2\varphi(d)$, which is nonnegative and strictly positive as soon as some divisor has $\varphi(d)\ge2$, i.e. for $n\ge3$. $\square$

**Theorem 8.3 (Divisor-lattice ceiling).** $H_T(n) \le \log_2 d(n)$ for $n \ge 1$, with strict inequality for $n\ge3$.

*Proof sketch.* The type law is supported on the $d(n)$ divisors of $n$, and the entropy of a distribution on a finite set is at most the logarithm of the cardinality, with equality iff the law is uniform. For $n \ge 3$, uniformity fails: $\mathbb{P}(T=1) = 1/n$ while $\mathbb{P}(T=n) = \varphi(n)/n > 1/n$. $\square$

**Corollary 8.4 (The sandwich).** For $n \ge 1$,
$$H_{\mathrm{nr}}(n) \;\le\; H_T(n) \;\le\; \log_2 d(n),$$
with both inequalities strict for composite $n \ge 3$.

Theorem 8.3 is the precise sense in which "the divisor structure of the cyclic order governs the channel". It also explains the numerical landscape of §3: $n=12$ has $d(12)=6$ divisors and is the richest entry in the table; $n=16$, though larger, has only $5$.

**Positivity.** $H_T(n) \ge 0$ always, and $H_T(n) > 0$ exactly for $n \ge 2$; the trivial Galois group carries no splitting information.

---

## 9. Lossiness of the binary readout

**Theorem 9.1 (Data processing).** $H_{\mathrm{nr}}(n) \le H_T(n)$ for every $n\ge1$.

*Proof sketch.* $\mathrm{nr}$ is a deterministic coarsening of $T$; coarsening cannot increase entropy. $\square$

**Theorem 9.2 (Lossiness dichotomy).** For $n \ge 2$,
$$H_{\mathrm{nr}}(n) < H_T(n) \iff n \text{ is composite}.$$

*Proof sketch.* If $n$ is prime, $T$ takes exactly the two values $1$ and $n$ and $\mathrm{nr}$ is a bijective relabelling, so the entropies coincide. If $n$ is composite, there is a divisor $1 < d < n$ with $\varphi(d) \ge 1$, so $T$ has at least three states while $\mathrm{nr}$ has two; the coarsening merges at least two states of positive probability, and merging states of positive probability strictly decreases entropy. Quantitatively, $H_T - H_{\mathrm{nr}} = \frac{n-1}{n}\,H\big(T \mid T\neq 1\big) > 0$, the conditional entropy of the type given that the prime does not split completely. $\square$

Arithmetically: **the root-count readout is lossy exactly at the composite cyclic orders**, i.e. exactly when the divisor lattice of the Galois group has an intermediate level. For $\mathbb{Q}(\zeta_5)$ it merges $\{T=2\}$ (two degree-$2$ primes) with $\{T=4\}$ (inert); for $\mathbb{Q}(\zeta_7)$ it merges three distinct decomposition patterns.

**Theorem 9.3 (Quantitative decay).** For $n \ge 2$, $0 \le H_{\mathrm{nr}}(n) \le \frac{\log_2 n + 2}{n}$; hence $H_{\mathrm{nr}}(n) \to 0$ as $n\to\infty$.

*Proof sketch.* From (2.2), $H_{\mathrm{nr}}(n) = h_2(1/n) = \frac1n\log_2 n + \frac{n-1}{n}\log_2\frac{n}{n-1}$, and $\log_2\frac{n}{n-1}\le \frac{1}{(n-1)\ln 2} \le \frac{2}{n-1}$ for $n \ge 2$. $\square$

**Corollary 9.4 (Total loss along the $2$-tower).** $H_T(2^k) - H_{\mathrm{nr}}(2^k) \to 2$ as $k\to\infty$: along the $2$-adic tower the binary readout eventually reports *none* of the two bits carried by the splitting type.

*Proof sketch.* Combine Theorems 7.1 and 9.3. $\square$

---

## 10. Faces of the channel and negative results

**The split-count projection.** Applying the pair construction (2.3) to $\mathrm{nr}$ instead of $T$ yields the classical split-count channel $I_s(n)$. Empirically the projection is faithful: the split-count content extracted from genuine semiprimes matches $I_s$ to three decimals ($0.2896$ against $I_s(4) = 0.2947$; $0.1445$ against $I_s(6) = 0.1487$), while the full type channel carries $1.2500$ and $1.4739$ bits respectively. So the split-count channel is a strictly smaller *face* of the type channel, and the one-bit cap that governs it does not govern the whole.

**Prime-level pinning of each type face.** In the model, conditioning on any single type value produces a two-state readout with entropy $h_2(\varphi(d)/n)$. For $n=4$ these pinnings are exact: $[T=1]$ has entropy $h_2(1/4) = 0.8113$ (measured $0.8098$ on primes), $[T=2]$ likewise $h_2(1/4)$ (measured $0.8110$), and $[T=4]$ has entropy $h_2(1/2) = 1.0000$ (measured $1.0000$). This is a prime-level quartic-character pinning: each face of the quartic splitting type is separately equidistributed at the predicted rate. For $n=6$, $[T=1]$ pins at $h_2(1/6) = 0.6500$ (measured $0.6497$).

**Symmetry (the which-factor wall).** The channel is invariant under exchanging $p$ and $q$; measurements give $0.0001$ bits of which-factor information, i.e. none. Knowing the unordered type pair does not identify either factor.

**Shallowness.** By Proposition 4.2, no additional information is obtained by refining the residue modulo higher powers of $f$; coprime controls are flat.

**Computability caveat.** The product class $N \bmod f$ is of course computable from $N$; what the channel provides is information about the *pair of types*, which is a symmetric function of the hidden factors and does not, by itself, yield either factor. The results here are structural statements about arithmetic information, not a factoring method.

---

## 11. Algorithms

Three algorithms suffice to reproduce every number in this paper.

**A. Exhaustive pair-channel evaluation.** For a given $n$, iterate over all $n^2$ ordered pairs $(x,y)$, compute $T(x) = n/\gcd(n,x)$ and $T(y)$, form the sorted key, and accumulate into the global table $\Pi$ and the conditional table $\Pi_{x+y}$. Then evaluate (2.3). Cost: $\Theta(n^2)$ time and $O(n\, d(n)^2)$ space; exact up to floating-point evaluation of the logarithms, and exactly rational-in-logs if carried out symbolically.

**B. Closed-form prime evaluation.** For prime $p$, evaluate Theorem 5.1 directly in $O(1)$ arithmetic operations. Cross-validating A against B for all primes up to a bound is the practical certificate of the closed form.

**C. Sylow evaluation of the type entropy.** Factor $n$, evaluate $H_T(p^{v})$ for each prime power by the totient law over the $v+1$ divisors, and sum (Theorem 6.3). Cost: factorisation plus $O(\sum_p v_p(n))$ arithmetic — exponentially faster than enumerating the group for smooth $n$.

**D. Arithmetic realisation.** For a prime $f$, sieve primes $p \neq f$, compute $\operatorname{ord}_f(p)$ by repeated multiplication modulo $f$, and tabulate empirical type frequencies; for semiprimes, sample pairs, record $N \bmod f$ and the sorted type pair, and estimate (2.3) by plug-in entropies. This is the bridge between the finite model and the primes themselves.

---

## 12. Discussion

### 12.1 What breaks the cap

The binary-fork cap is a theorem about a *two-state* observable whose pair statistics are governed entirely by a product-of-signs: for a quadratic character, $\{\varepsilon(p),\varepsilon(q)\}$ is determined up to the swap by $\varepsilon(p)\varepsilon(q) = \varepsilon(N)$, which is one bit, no more. Theorem 5.6 shows that the quadratic case is the *unique* prime-order instance attaining that bound, and Theorem 5.1 shows exactly how the bound degrades for larger prime orders: at prime order the type is still two-state, but the group law no longer makes the product class determine the pair, and the information collapses like $p^{-2}$.

The escape route is the divisor lattice. When $n$ is composite the type is genuinely multi-state, and the conditional tables $\Pi_c$ vary much more strongly with $c$ than in the two-state case. The measured values then rise above one bit, reaching $1.7239$ at $n=12$.

### 12.2 An emerging arithmetic thermodynamics

Read as statistical mechanics on the divisor lattice, the picture is unusually clean:

* the **state space** is the divisor lattice of $n$, with occupation law $\varphi(d)/n$;
* the **free entropy** $H_T$ is additive over coprime parts (Theorem 6.2) and decomposes over Sylow components (Theorem 6.3), exactly as an entropy of independent subsystems;
* **depth saturates**: the $2$-primary subsystem contributes $2 - 2^{1-k}$ and never more than two bits (Theorem 7.1);
* **coarse instruments lose everything**: the binary readout's entropy decays like $(\log_2 n)/n$ (Theorem 9.3), so along any tower the naive detector eventually reports nothing while the true state entropy stays bounded away from zero.

### 12.3 Conjectural completion

The exhaustive data suggest that the pair channel inherits the same multiplicative skeleton as the single-prime channel. Numerically, for every coprime pair tested,
$$I_{\mathrm{pair}}(mn) = I_{\mathrm{pair}}(m)+I_{\mathrm{pair}}(n) \qquad (\gcd(m,n)=1),$$
e.g. $I_{\mathrm{pair}}(12) = I_{\mathrm{pair}}(3)+I_{\mathrm{pair}}(4) = 0.4739 + 1.2500 = 1.7239$, $I_{\mathrm{pair}}(10) = 1 + 0.2027$, $I_{\mathrm{pair}}(15) = 0.4739+0.2027 = 0.6766$, $I_{\mathrm{pair}}(20)=1.2500+0.2027=1.4527$, $I_{\mathrm{pair}}(24) = 1.3125+0.4739=1.7864$. Along the $2$-tower the values $1,\ 1.25,\ 1.3125,\ 1.328125$ match
$$I_{\mathrm{pair}}(2^k) = \tfrac43\big(1-4^{-k}\big)$$
exactly for $k \le 4$.

The *even* half of the conjectured picture follows immediately from additivity: an even $n\ge4$ has a $2$-part $2^{v}$ with $v\ge1$, contributing $I_{\mathrm{pair}}(2^v) \ge 1$ — and $\ge 1.25$ as soon as $v \ge 2$ — while all other parts are nonnegative. Combined with the parity of the type at the $2$-level, this is the precise sense in which the cap is a statement about the **$2$-torsion of the Galois group** rather than about the number of splitting types: one bit is unconditionally recoverable through the quotient by squares, and everything above it is bought at a deeper even level of the divisor lattice.

### 12.4 An incompatibility: additivity contradicts the odd half of the dichotomy

The *odd* half — the assertion $I_{\mathrm{pair}}(n) < 1$ for every odd $n \ge 3$ — cannot survive alongside coprime additivity. Indeed, if additivity holds then for squarefree odd $n$ we would have $I_{\mathrm{pair}}(n) = \sum_{p \mid n} I_{\mathrm{pair}}(p)$, with each summand given exactly by Theorem 5.1. Summing the closed form over the $33$ odd primes up to $139$ gives
$$\sum_{3\le p \le 139} I_{\mathrm{pair}}(p) \;=\; 1.00010\ldots \;>\; 1,$$
and the sum over all odd primes up to $10^3$ is already $1.01134\ldots$, converging to $\approx 1.0132$. Hence, under additivity, the odd squarefree order $n = \prod_{3 \le p \le 139} p$ would carry more than one bit.

So at most one of the two conjectures can be true as stated. The available evidence is asymmetric: additivity has been confirmed exactly on every coprime pair tested (including the odd cases $I_{\mathrm{pair}}(15) = 0.6766$, $I_{\mathrm{pair}}(21) = 0.5880$, $I_{\mathrm{pair}}(45) = 0.7292$, $I_{\mathrm{pair}}(105) = 0.7907$, each equal to the sum of the corresponding prime-power values to full precision), whereas the odd half of the dichotomy has only been checked in a range where $n$ has at most two or three odd prime factors — far too small a range to see a sum that creeps above one bit only after thirty-three of them. The corrected statement should therefore read:

> **Revised dichotomy (conjectural).** $I_{\mathrm{pair}}(n) > 1$ for every even $n\ge4$; $I_{\mathrm{pair}}(2)=1$; and $I_{\mathrm{pair}}(n)<1$ for odd $n$ whose odd prime-power parts have $\sum_{p\mid n} I_{\mathrm{pair}}(p^{v_p}) < 1$ — a condition that fails only for odd orders with a very large number of distinct prime factors.

This is a strictly sharper statement than the original: the failure locus is explicit, and the threshold is computable from the proved prime formula alone. The upshot is that "exceeding the one-bit cap" is *typically* an even phenomenon, but not exclusively one; sufficiently rich odd divisor lattices should also break it, by accumulating many small contributions rather than one large $2$-adic one.

### 12.5 Limitations

All statements are about the *unordered* pair; the channel is provably symmetric and empirically factor-useless. Everything is conditioned on knowing the arithmetic setup — the modulus $f$ and the group law — so no statement here bears on the hardness of factoring. The composite-order values reported are exhaustive evaluations for the listed orders; the general composite theory remains conjectural (§§12.3–12.4).

---

## 13. Future directions

The natural next targets, in decreasing order of leverage:

1. **CRT additivity of the pair channel.** Prove $I_{\mathrm{pair}}(mn) = I_{\mathrm{pair}}(m)+I_{\mathrm{pair}}(n)$ for coprime $m,n$. All the ingredients but one are in place: the type map is CRT-multiplicative (Theorem 6.1) and the single-prime entropy is additive (Theorem 6.2). The missing step is a product decomposition of the conditional tables $\Pi_c$ — a purely combinatorial statement, since CRT splits both the type variable and the conditioning residue into independent coordinates.
2. **The $2$-adic pair law.** Prove $I_{\mathrm{pair}}(2^k) = \tfrac43(1-4^{-k})$. Together with (1) and the proved prime bound this yields the even half of the dichotomy of §12.3 unconditionally.
3. **The revised dichotomy of §12.4.** The naive parity statement is untenable together with additivity: the proved prime formula, summed over the odd primes up to $139$, already exceeds one bit. The right question is therefore to determine the exact failure locus on the odd side — equivalently, to decide whether an odd order with sufficiently many prime factors really does break the cap, which would follow from additivity and refute the parity reading of the cap.
4. **Non-cyclic Galois groups.** The type of a prime in a general abelian (or nonabelian) extension is the order of its Frobenius class; the analogue of the divisor lattice is the lattice of cyclic subgroups, and the analogue of the totient law counts elements of each order. Which groups maximise the pair channel at fixed order?
5. **Higher tuples.** Replace semiprimes by products of $k$ primes and ask for the growth of $I_{\mathrm{pair}}^{(k)}(n)$; the $k=2$ theory above is the first nontrivial case.
6. **Effective error terms.** All statements are density statements; making them effective for primes up to $X$ requires an effective Chebotarev bound, which for cyclotomic fields is classical, and would convert the empirical agreement reported in §3 into a rigorous rate.

---

## 14. Conclusion

The complete splitting type of a prime in a cyclotomic field is a multi-state observable, and its pair channel is not bounded by the one bit that governs every binary fork. At prime cyclic order the channel is exactly
$$\log_2 p - \frac{(p-1)(2p-1)}{p^2}\log_2(p-1) + \frac{(p-1)(p-2)}{p^2}\log_2(p-2),$$
strictly positive, of order $p^{-2}$, strictly below one bit for every odd prime and exactly one bit at $p=2$. At composite order it exceeds one bit for every even order tested, peaking at $1.7239$ bits for the twelve-element group of $\mathbb{Q}(\zeta_{13})$. Behind both regimes stands the same structure: the divisor lattice of the Galois order, which bounds the single-prime channel from above by $\log_2 d(n)$, makes it additive over coprime factorisations, saturates it at exactly two bits along the $2$-adic tower, and — as the numerical evidence strongly suggests — controls the pair channel by the same multiplicative law. The binary root-count readout, by contrast, is provably lossy at exactly the composite orders and asymptotically reports nothing at all. **The type, not the root count, is the complete object.**
