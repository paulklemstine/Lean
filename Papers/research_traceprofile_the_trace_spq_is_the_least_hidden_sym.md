# The Trace of a Semiprime is the Least Hidden Symmetric Invariant

### Exactly one bit per prime, the Legendre symbol as the visible bit, the low-bit law $s_1 = 1 - N_1$, and a counting barrier

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

Let $N = pq$ be a semiprime with odd prime factors and let $s = p + q$ be its **trace**. The pair $(N, s)$ determines $\{p, q\}$ as the roots of $X^2 - sX + N$, so the trace is the minimal factor-bearing symmetric witness of the factorisation. We give a complete description of how much the public modulus $N$ constrains the residues of $s$, and we contrast it with the corresponding question for the factor $p$ itself.

Three phenomena are established. First, **factor invisibility**: modulo an odd prime $\ell$ the set of residues a factor of a nonzero $N$ may occupy is the full unit group $\mathbb{F}_\ell^\times$, and the counting form of statistical independence holds exactly, so the mutual information $I(p \bmod \ell \,;\, N \bmod \ell)$ vanishes identically. Second, **trace visibility, quantified exactly**: the trace set $S_\ell(N) = \{x + y : xy = N\} \subseteq \mathbb{F}_\ell$ admits the discriminant description $S_\ell(N) = \{s : s^2 - 4N \text{ is a square}\}$ and has size given by
$$2\,|S_\ell(N)| = \ell + \chi_\ell(N),$$
where $\chi_\ell$ is the quadratic character; the trace set is multiplicative across coprime moduli, whence for squarefree odd $M$ coprime to $N$ the density of $S_M(N)$ is $2^{-\omega(M)}$ up to the corrections $1 \pm 1/\ell$ — exactly one bit per prime, additively independent. At the bottom of the binary expansion the constraint becomes an identity: $p + q + pq \equiv 3 \pmod 4$ for all odd $p, q$, i.e. $s_1 = 1 - N_1$, sharp in the sense that no analogous law holds modulo $8$ (bit $2$ agrees with the naive prediction with probability exactly $3/4$). Third, **the visible information is public and does not scale**: the deviation of $|S_\ell(N)|$ from $\ell/2$ is precisely the Legendre symbol $\chi_\ell(N)$, computable from $N$ in polynomial time, so the trace-set size distinguishes moduli only through that public bit; and a counting barrier shows that congruence data modulo $M = \prod_{\ell \in P} \ell$ leaves at least $\left(\prod (\ell-1)\right)(B/M - 1)/2^{|P|}$ candidate traces in a window $[1,B]$, so pinning $s$ requires $|P| \gtrsim \log_2 N$ primes and hence a modulus far exceeding $N$.

Finally we show that the phenomenon is strictly an arity-$2$ effect: the two-factor trace set is always a proper subset of $\mathbb{F}_\ell$, whereas the three-factor sum set $\{x+y+z : xyz = N\}$ is already all of $\mathbb{F}_{11}$ for every invertible $N$, with $\ell \in \{3,5,7\}$ the only exceptions. The trace constraint is the quadratic discriminant, and nothing else.

**Keywords:** semiprime, trace, quadratic character, Legendre symbol, trace set, Chinese Remainder Theorem, mutual information, factoring barriers, discriminant, arity.

---

## 1. Introduction

### 1.1 The question

The security of factoring-based cryptography is usually discussed in the language of computational complexity. There is a parallel and more elementary question that is rarely asked in a sharp form: **how much information about a factorisation is present in the public modulus at all?**

Fix a semiprime $N = pq$ with $p, q$ odd primes. There are two natural hidden quantities:

* the **factor** $p$ (equivalently $q$), which is *asymmetric* — it distinguishes the two primes; and
* the **trace** $s = p + q$, which is *symmetric*.

The trace deserves the attention because it is exactly as good as the factorisation itself. Given $(N, s)$, the primes are the roots of
$$X^2 - sX + N = 0, \qquad p, q = \frac{s \pm \sqrt{s^2 - 4N}}{2}. \tag{1.1}$$
So $s$ is a *minimal factor-bearing symmetric witness*: one number, symmetric in the factors, from which the factorisation follows by a single square root. Any residue-based attack on $N$ that hopes to avoid asymmetry must target $s$ or something like it.

The natural probes are congruences. What does $N \bmod m$ tell us about $s \bmod m$? About $p \bmod m$?

### 1.2 The empirical picture

A large computational study over semiprime pairs with $k$-bit factors ($k = 12, 14$; between $32\,640$ and $380\,628$ pairs; mutual information estimated modulo $m$; Chinese-Remainder trace-set sizes; full pairwise bit matrices) produced the following readings.

1. $I(p \bmod m \,;\, N \bmod m) \approx 0$ for every modulus $m$ tested — a "zero block".
2. $I(s \bmod m \,;\, N \bmod m) = 1.0000$ bit at $m = 3$ and $1.03$–$1.06$ bits at larger odd primes, tracking the trace-set size $\approx (m+1)/2$.
3. Jointly, $|S_{M}(N)|/M = 2^{-\omega(M)}$ for primorial $M$: measured $0.5011$, $0.2509$, $0.1260$, each prime halving the set.
4. An exact low-bit relation $s_1 = 1 - N_1$, holding on $300\,000$ of $300\,000$ sampled pairs; and a partial relation at bit $2$ holding with probability $0.754$.
5. In the pairwise bit matrix, $2.32$ bits of the trace's $H(s) = 12.6$ bits are visible ($18.5$–$21.9\%$), versus about $5\%$ for the factor.

This paper proves the exact theorems behind items 1–4, identifies precisely *which* bit is visible in item 2, explains item 5 structurally, and proves the negative result that makes the whole profile harmless.

### 1.3 Results and organisation

Section 2 fixes definitions. Section 3 proves factor invisibility as an exact product rule. Section 4 develops the trace set: its structure as a discriminant locus, its exact size over a prime field, its multiplicativity, and the joint one-bit-per-prime law. Section 5 identifies the visible bit with the Legendre symbol and derives the indistinguishability statement. Section 6 proves the exact low-bit theorem, its $k$-factor generalisation, and its sharpness. Section 7 establishes the arity-$2$/arity-$3$ dichotomy. Section 8 proves the pinning barrier. Section 9 discusses the residual question — the trace set as a complete invariant — and lists open conjectures.

---

## 2. Definitions

Throughout, $R$ denotes a finite commutative ring with identity, and $\ell$ an odd prime. We write $\mathbb{F}_\ell = \mathbb{Z}/\ell\mathbb{Z}$, and $\chi_\ell$ for the quadratic character: $\chi_\ell(N) = +1$ if $N$ is a nonzero square mod $\ell$, $-1$ if $N$ is a non-square, $0$ if $\ell \mid N$.

> **Definition 2.1 (Factor pairs).** For $N \in R$, the set of ordered factorisations is
> $$\mathrm{FP}_R(N) = \{(x,y) \in R \times R : xy = N\}.$$

> **Definition 2.2 (Trace set).** The **trace set** of $N \in R$ is the image of $\mathrm{FP}_R(N)$ under the sum map,
> $$S_R(N) = \{\, x + y \;:\; xy = N \,\} \subseteq R.$$
> For $R = \mathbb{Z}/m\mathbb{Z}$ we write $S_m(N)$.

> **Definition 2.3 (Factor set).** The **factor set** of $N \in R$ is the image of $\mathrm{FP}_R(N)$ under the first projection,
> $$F_R(N) = \{\, x \;:\; \exists y,\ xy = N \,\}.$$

The trace set is the complete list of residues that the true trace $s = p+q$ of a factorisation of $N$ can occupy modulo $m$; likewise $F_m(N)$ for the factor. Constraint on the hidden quantity is exactly the statement that these sets are small.

> **Definition 2.4 (Triple sum set).** For $N \in R$,
> $$T_R(N) = \{\, x + y + z \;:\; xyz = N \,\} \subseteq R,$$
> the arity-$3$ analogue of the trace set.

> **Definition 2.5 (Unit-pair model).** For a prime $\ell$, the uniform sample space $U_\ell = \{(x,y) \in \mathbb{F}_\ell^\times \times \mathbb{F}_\ell^\times\}$, of cardinality $(\ell-1)^2$, models the pair of factor residues of a random semiprime coprime to $\ell$. Mutual information statements are made in the counting form: two events *satisfy the product rule* when
> $$\#\{\text{joint}\} \cdot \#U_\ell = \#\{\text{first}\} \cdot \#\{\text{second}\},$$
> which is exactly the vanishing of the corresponding contribution to mutual information.

---

## 3. Factor invisibility: an exact zero

The first half of the empirical zero block is a triviality once stated correctly, but it is worth stating correctly, because it is what makes the trace results surprising.

> **Theorem 3.1 (Factor invisibility).** Let $\ell$ be a prime and $N \in \mathbb{F}_\ell$, $N \ne 0$. Then
> $$F_{\mathbb{F}_\ell}(N) = \mathbb{F}_\ell^\times, \qquad |F_{\mathbb{F}_\ell}(N)| = \ell - 1 .$$
> Moreover, for each $a \in \mathbb{F}_\ell^\times$ and $b \in \mathbb{F}_\ell$ there is exactly one $y$ with $ay = b$.

*Proof.* If $xy = N \ne 0$ then $x \ne 0$. Conversely, for any $x \ne 0$, the element $y = N x^{-1}$ satisfies $xy = N$. So the factor set is exactly the unit group, of size $\ell - 1$. Uniqueness of the cofactor is invertibility of $a$. $\square$

Thus the residue $N \bmod \ell$ excludes no candidate residue for the factor. The stronger, distributional statement is:

> **Theorem 3.2 (Exact independence; $I(p \bmod \ell \,;\, N \bmod \ell) = 0$).** In the unit-pair model $U_\ell$, for all $a, b \in \mathbb{F}_\ell^\times$,
> $$\#\{(x,y) \in U_\ell : x = a,\ xy = b\} \cdot |U_\ell| \;=\; \#\{(x,y) \in U_\ell : x = a\} \cdot \#\{(x,y) \in U_\ell : xy = b\}.$$

*Proof sketch.* The three counts are computed exactly. The joint event is the single point $(a, a^{-1}b)$, so its count is $1$. The first marginal is $\{a\} \times \mathbb{F}_\ell^\times$, of size $\ell - 1$. The second marginal is the image of the injective map $x \mapsto (x, x^{-1}b)$ on $\mathbb{F}_\ell^\times$, also of size $\ell - 1$. Since $|U_\ell| = (\ell-1)^2$, both sides equal $(\ell-1)^2$. $\square$

Every term of the mutual information sum vanishes, so $I = 0$ exactly, not approximately. The measured zero block is not a small-sample artefact: **the public residue of a semiprime is a perfect one-time pad for the residues of its factors**, at every modulus, at every scale. This is Barrier 2 at the information level: no congruence observation of $N$ carries evidence about $p \bmod \ell$.

---

## 4. The trace set: structure, exact size, and the joint law

### 4.1 The discriminant description

> **Theorem 4.1 (Discriminant description).** Let $\ell$ be an odd prime and $N, s \in \mathbb{F}_\ell$. Then
> $$s \in S_\ell(N) \iff s^2 - 4N \text{ is a square in } \mathbb{F}_\ell.$$

*Proof.* If $s = x + y$ with $xy = N$, then $(x-y)^2 = (x+y)^2 - 4xy = s^2 - 4N$, so the discriminant is a square. Conversely, if $s^2 - 4N = t^2$, set $x = (s+t)/2$ and $y = (s-t)/2$ (legitimate since $2$ is invertible). Then $x + y = s$ and $xy = (s^2 - t^2)/4 = N$. $\square$

This is the structural heart of everything that follows: **the trace obeys exactly one quadratic condition**, so it can be constrained by exactly one bit and no more.

### 4.2 The exact size over a prime field

> **Theorem 4.2 (Exact trace-set size).** Let $\ell$ be an odd prime and $N \in \mathbb{F}_\ell^\times$. Then
> $$2\,|S_\ell(N)| \;=\; \ell + \chi_\ell(N) \;=\; \begin{cases} \ell + 1, & N \text{ a nonzero square},\\ \ell - 1, & N \text{ a non-square}.\end{cases}$$

*Proof sketch.* Parametrise: since $N \ne 0$, every factorisation has $x \ne 0$ and $y = N/x$, so
$$S_\ell(N) = \{\, x + Nx^{-1} : x \in \mathbb{F}_\ell^\times \,\},$$
the image of a map $\varphi$ from a set of size $\ell - 1$. Count fibres. For $s \in S_\ell(N)$ realised as $x_0 + y_0$ with $x_0 y_0 = N$, the equation $x + Nx^{-1} = s$ is equivalent to the quadratic $x^2 - sx + N = 0$, whose root set is $\{x_0, y_0\}$; so the fibre has $2$ elements unless $x_0 = y_0$, i.e. unless $s^2 = 4N$, in which case it has $1$. Hence
$$\ell - 1 \;=\; \sum_{s \in S_\ell(N)} |\varphi^{-1}(s)| \;=\; \#\{s \in S_\ell(N) : s^2 = 4N\} + 2\,\#\{s \in S_\ell(N) : s^2 \ne 4N\}.$$
It remains to count the degenerate traces. If $N = r^2$ with $r \ne 0$, the condition $s^2 = 4N$ factors as $(s - 2r)(s + 2r) = 0$ and $2r \ne -2r$, so there are exactly $2$ such $s$, both genuinely in $S_\ell(N)$ (realised by $r\cdot r$ and $(-r)(-r)$). If $N$ is a non-square there are none, since $s^2 = 4N$ would exhibit $N = (s/2)^2$. Writing $d$ for that count and $c = |S_\ell(N)|$, we get $\ell - 1 = d + 2(c - d) = 2c - d$, i.e. $2c = \ell - 1 + d$ with $d \in \{2, 0\}$. $\square$

Two immediate corollaries. First, $|S_\ell(N)| < \ell$: the trace set is always a **proper** subset, so the trace really is constrained. Second, the constraint is of size exactly one bit:
$$\log_2 \frac{\ell}{|S_\ell(N)|} \;=\; 1 + O(1/\ell).$$
This refines the experimental reading $(m+1)/2$: the true value is $(m + \chi_m(N))/2$, a $\pm 1$ correction invisible at the measured precision but exact.

### 4.3 Multiplicativity

> **Theorem 4.3 (Product rings).** For finite commutative rings $R, S$ and $N \in R$, $M \in S$,
> $$S_{R \times S}\big((N, M)\big) = S_R(N) \times S_S(M), \qquad |S_{R\times S}((N,M))| = |S_R(N)| \cdot |S_S(M)|.$$

*Proof.* A factorisation $(x_1,x_2)(y_1,y_2) = (N,M)$ in the product ring is precisely a pair of factorisations $x_1y_1 = N$, $x_2y_2 = M$, and the sum is computed componentwise. $\square$

The trace set is also transported by any ring isomorphism $e : R \to S$, in the strong form $S_S(e(N)) = e\big(S_R(N)\big)$, hence sizes agree. Combining with the Chinese Remainder isomorphism $\mathbb{Z}/mn\mathbb{Z} \cong \mathbb{Z}/m\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$:

> **Corollary 4.4 (CRT multiplicativity).** For coprime $m, n \ge 1$ and $N \in \mathbb{Z}$,
> $$|S_{mn}(N)| = |S_m(N)| \cdot |S_n(N)|.$$

By induction, for a squarefree $M = \prod_{\ell \in P} \ell$, $\;|S_M(N)| = \prod_{\ell \in P} |S_\ell(N)|$.

### 4.4 The joint law: one bit per prime

> **Theorem 4.5 (One bit per prime, additively independent).** Let $P$ be a finite set of odd primes, $M = \prod_{\ell \in P} \ell$, and $N$ an integer divisible by no $\ell \in P$. Then
> $$\prod_{\ell \in P}(\ell - 1) \;\le\; 2^{|P|} \, |S_M(N)| \;\le\; \prod_{\ell \in P}(\ell + 1).$$

*Proof.* By Corollary 4.4 and Theorem 4.2,
$$2^{|P|}|S_M(N)| = \prod_{\ell \in P} \big(2|S_\ell(N)|\big) = \prod_{\ell \in P}\big(\ell + \chi_\ell(N)\big),$$
and each factor lies in $\{\ell - 1, \ell + 1\}$. $\square$

Dividing by $M$:
$$\frac{|S_M(N)|}{M} = 2^{-|P|}\prod_{\ell \in P}\left(1 + \frac{\chi_\ell(N)}{\ell}\right) = 2^{-\omega(M)}\big(1 + O(\textstyle\sum_{\ell} 1/\ell)\big),$$
which is the measured law $0.5011, 0.2509, 0.1260, \dots$ For the primorial $M = 3 \cdot 5 \cdot 7 = 105$, for instance, the density lies between $2^{-3}\prod_{\ell}(1 - 1/\ell) = 0.0571\ldots$ and $2^{-3}\prod_{\ell}(1 + 1/\ell) = 0.2285\ldots$, and equals $2^{-3} = 0.125$ up to the character corrections, which largely cancel when the symbols are mixed. The information content is
$$\log_2 \frac{M}{|S_M(N)|} = \omega(M) - \sum_{\ell \in P}\log_2\left(1 + \frac{\chi_\ell(N)}{\ell}\right) = \omega(M) + O(1),$$
i.e. **the bits are additive across primes with no interaction whatsoever** — the exact meaning of the experimental phrase "additively independent".

### 4.5 The size contrast

Putting Theorems 3.1 and 4.2 side by side in a single normalisation:

> **Theorem 4.6 (Trace bit versus factor bits).** For an odd prime $\ell$ and $N \in \mathbb{F}_\ell^\times$,
> $$2\,|S_\ell(N)| \;\le\; |F_{\mathbb{F}_\ell}(N)| + 2 \;=\; \ell + 1,$$
> and for $\ell \ge 5$ strictly $|S_\ell(N)| < |F_{\mathbb{F}_\ell}(N)|$.

The factor occupies $\ell - 1$ residues (zero bits of constraint); the trace occupies about $\ell/2$ (one bit). That the trace should also fail the independence test is a separate, finite check:

> **Proposition 4.7 (The trace is not information-free).** In the unit-pair model at $\ell = 5$, with trace value $s = 2$ and product value $b = 1$, the product rule fails: $1 \cdot 16 \ne 3 \cdot 4$. Hence $I(s \bmod 5 \,;\, N \bmod 5) > 0$.

So the contrast measured in the experiment — zero for the factor, one bit for the trace — is exact on both sides.

---

## 5. Which bit is visible? The Legendre symbol

Theorem 4.2 does more than count. It *names* the visible bit.

> **Theorem 5.1 (The visible bit is the quadratic character).** For an odd prime $\ell$ and an integer $a$ with $\ell \nmid a$,
> $$2\,|S_\ell(a)| = \ell + \left(\frac{a}{\ell}\right),$$
> where $\left(\frac{a}{\ell}\right)$ is the Legendre symbol.

*Proof.* Immediate from Theorem 4.2 and the definition of the Legendre symbol as $+1$ on nonzero squares and $-1$ on non-squares. $\square$

> **Corollary 5.2 (Character-indistinguishability).** If $a, b$ are integers not divisible by $\ell$ and $\left(\frac{a}{\ell}\right) = \left(\frac{b}{\ell}\right)$, then $|S_\ell(a)| = |S_\ell(b)|$.

*Proof.* Both sides of Theorem 5.1 agree; cancel the factor $2$. $\square$

The significance is cryptographic rather than arithmetic. **The Legendre symbol $\left(\frac{N}{\ell}\right)$ is computable from $N$ alone in polynomial time**, by quadratic reciprocity — no knowledge of $p$ or $q$ is required. Hence:

* The single bit that the trace constraint exposes at each prime is *public data*, already available to any observer of $N$.
* By Corollary 5.2, the *size* of the constraint distinguishes two moduli only when their characters differ. It contains no residual information about the factorisation.

This is the information-level form of the paper's central verdict: the trace is the least hidden symmetric invariant, but what is visible about it is a shadow of a quantity that was never hidden. There is no leak, only a reflection.

The same statement explains item 5 of the empirical picture. The pairwise bit matrix found $2.32$ visible bits out of $H(s) = 12.6$, i.e. $18.5$–$21.9\%$, versus $\approx 5\%$ for the factor. The visible portion decomposes into (i) the exact low-bit relations of Section 6, which are functions of $N \bmod 4$, and (ii) a thin sliver at the top of the expansion from the carry-out of $p + q$ — both symmetric, both public-derivable, neither isolating $p$ or $q$.

---

## 6. The exact low-bit law

At the prime $2$ the quadratic-character analysis degenerates, and something better happens: an identity.

> **Theorem 6.1 (Exact low-bit theorem, sharp form).** For all odd integers $p, q$,
> $$p + q + pq \equiv 3 \pmod 4.$$

*Proof.* Write $p = 2a+1$, $q = 2b+1$. Then $p + q + pq = (2a+1) + (2b+1) + (2a+1)(2b+1) = 4(a + b + ab) + 3$. $\square$

Equivalently $4 \mid (p+1)(q+1)$. Rewriting in terms of $N = pq$, $s = p+q$:

> **Corollary 6.2 (Bit form).** For odd $p, q$,
> $$s \bmod 4 = \begin{cases} 2, & N \equiv 1 \pmod 4,\\ 0, & N \equiv 3 \pmod 4.\end{cases}$$
> In binary digits, writing $x_i$ for bit $i$ of $x$ (so $x_1 = \lfloor x/2 \rfloor \bmod 2$), the trace satisfies
> $$s_1 = 1 - N_1, \qquad\text{i.e.}\qquad \mathrm{bit}_1(s) = \neg\,\mathrm{bit}_1(N).$$

*Proof.* From Theorem 6.1, $s \equiv 3 - N \pmod 4$; odd $N$ has $N \bmod 4 \in \{1,3\}$; and $s$ is even since $p, q$ are odd, which pins $s \bmod 4$ to $2$ or $0$ respectively. Bit $1$ of an even number $s$ is $(s \bmod 4)/2$, and bit $1$ of an odd $N$ is $(N \bmod 4 - 1)/2$; substituting gives the complement relation. $\square$

This is exactly the experimental finding: the relation held on $300\,000$ of $300\,000$ sampled pairs, because it is a theorem with no exceptions.

> **Corollary 6.3 (Zero marginal information).** If $p,q,p',q'$ are odd with $pq \equiv p'q' \pmod 4$, then $p + q \equiv p' + q' \pmod 4$.

*Proof.* Both sides are the same function of the common value $N \bmod 4$, by Corollary 6.2. $\square$

So the exactly-visible bit of the trace is a *deterministic function of the public modulus*; it carries no information about the factorisation beyond what $N$ already gives. Once again: visible, and useless.

### 6.1 Sharpness

> **Theorem 6.4 (No law at bit 2).** There exist odd pairs with the same $N \bmod 8$ but different $s \bmod 8$. Explicitly $(p,q) = (3,3)$ and $(p',q') = (5,13)$ give $N = 9 \equiv 1$ and $N' = 65 \equiv 1 \pmod 8$, while $s = 6$ and $s' = 18 \equiv 2 \pmod 8$.

Hence no relation of the form $s_2 = f(N_2)$, or indeed $s \bmod 8 = f(N \bmod 8)$, can hold. What survives is a statistic:

> **Theorem 6.5 (The $3/4$ law).** In the uniform model over pairs of odd residues modulo $8$ — which is all that $s \bmod 8$ and $N \bmod 8$ depend on — bit $2$ of the trace differs from bit $2$ of the modulus for exactly $12$ of the $16$ pairs, i.e. with probability $3/4$.

The experiment measured $0.754$, in agreement within sampling error. The two results together delimit precisely how far the exact regime extends: bit $0$ of $s$ is forced ($s$ is even), bit $1$ is forced by $N$, and from bit $2$ onwards only probabilities remain.

### 6.2 The $k$-factor generalisation

The low-bit law is not special to two factors — it is special to *counting* factors.

> **Theorem 6.6 ($k$-factor low-bit law).** Let $a_1, \dots, a_k$ be odd integers, $N = \prod_i a_i$ and $e_1 = \sum_i a_i$ the first symmetric function. Then
> $$e_1 + 1 \equiv N + k \pmod 4 .$$

*Proof sketch.* Induction on the length of the list of factors. For the empty list, $e_1 = 0$, $N = 1$, $k = 0$, and indeed $0 + 1 \equiv 1 + 0 \pmod 4$. For the inductive step, write the head as $a = 2x+1$ and let $\Pi$ be the product of the tail, odd, say $\Pi = 2y+1$. Then $a\Pi = 4xy + 2x + 2y + 1$, so modulo $4$ the new product differs from the old by a controlled amount; combining with the inductive hypothesis for the tail and $e_1^{\text{new}} = a + e_1^{\text{tail}}$, the claim follows by linear arithmetic modulo $4$. $\square$

For $k = 2$ this reads $s + 1 \equiv N + 2 \pmod 4$, i.e. $p + q + 1 \equiv pq + 2$, which is Theorem 6.1 rearranged. The lesson: the exactly-visible low bit of the first symmetric function of an odd factorisation is a function of the product and the *number of factors* — never of the factors themselves.

---

## 7. Arity: the trace constraint is a two-factor phenomenon

Sections 4–6 might suggest that symmetric functions of factorisations are generally constrained modulo primes. They are not. The constraint is precisely the existence of a quadratic discriminant, and it disappears at arity $3$.

> **Definition 7.1.** $T_R(N) = \{x + y + z : xyz = N\}$.

> **Proposition 7.2 (Arity monotonicity).** For any finite commutative ring $R$ and $N \in R$, $|S_R(N)| \le |T_R(N)|$.

*Proof.* If $xy = N$ then $xy\cdot 1 = N$, so $x + y + 1 \in T_R(N)$. Thus the injective translate $s \mapsto s+1$ maps $S_R(N)$ into $T_R(N)$. $\square$

> **Theorem 7.3 (Properness at arity 2).** For every odd prime $\ell$ and $N \in \mathbb{F}_\ell^\times$, $S_\ell(N) \ne \mathbb{F}_\ell$.

*Proof.* By Theorem 4.2, $|S_\ell(N)| \le (\ell+1)/2 < \ell$ for $\ell \ge 3$. $\square$

> **Theorem 7.4 (Arity-3 collapse at $\ell = 11$).** For every $N \in \mathbb{F}_{11}^\times$, $T_{11}(N) = \mathbb{F}_{11}$. Consequently the three-factor sum carries zero bits at $\ell = 11$, in contrast to the one bit of the two-factor trace.

This is an exhaustive finite verification over the $10 \cdot 11^3$ relevant configurations. Combined with Theorem 7.3:

> **Corollary 7.5 (Arity dichotomy at $\ell = 11$).** For every $N \in \mathbb{F}_{11}^\times$: $S_{11}(N) \subsetneq \mathbb{F}_{11}$ while $T_{11}(N) = \mathbb{F}_{11}$.

Small primes are genuinely exceptional:

> **Theorem 7.6 (Exception at $\ell = 5$).** $T_5(1) \ne \mathbb{F}_5$.

Indeed, over $\mathbb{F}_5$ no triple with product $1$ sums to $2$. Computationally, $\ell = 3, 5, 7$ are the only primes at which the arity-$3$ sum set fails to be everything; from $11$ upwards the collapse is total (verified to $\ell \le 19$).

**Why $11$?** Heuristically, $s \in T_\ell(N)$ asks for a solution of $xyz = N$, $x+y+z=s$. Eliminating, one seeks $z \ne 0$ with $x + y = s - z$ and $xy = N/z$, i.e. with the discriminant $(s-z)^2 - 4N/z$ a square. Clearing denominators, that is
$$w^2 = z^2(s-z)^2 - 4Nz,$$
a quartic model of a curve of genus $1$. The Hasse–Weil bound gives $\ell + O(\sqrt{\ell})$ points, so a point with $z \ne 0$ exists once $\ell$ is large enough; the numerics say "large enough" means $\ell \ge 11$. The contrast is exactly the contrast between a **conic** (arity $2$: one quadratic condition, half the residues, one bit) and an **elliptic curve** (arity $3$: enough points to hit every $s$, zero bits).

The trace constraint is the quadratic discriminant, and nothing else.

---

## 8. The pinning barrier: why one bit per prime is not an attack

We now prove the negative half. The trace's visible bits are additive: $\omega(M)$ of them for a modulus with $\omega(M)$ prime factors. The search space is exponential. That mismatch is fatal to any residue-based attack.

First, the window.

> **Lemma 8.1 (Search window).** If $p, q \ge 2$ then $p + q \le pq = N$. So the trace lies in $[1, N]$.

*Proof.* $(p-1)(q-1) \ge 1$ rearranges to $pq \ge p + q$. $\square$

Next, a counting lemma: congruences cannot thin a long interval below its natural density.

> **Lemma 8.2 (Residue classes meet the window).** For $M \ge 1$, $B \ge 0$ and any $s \in \mathbb{Z}/M\mathbb{Z}$,
> $$\#\{\,t \in [1,B] : t \equiv s \ (\mathrm{mod}\ M)\,\} \;\ge\; \lfloor B/M \rfloor - 1 .$$

*Proof.* Write $K = \lfloor B/M \rfloor$; if $K < 2$ the bound is vacuous. Otherwise the $K-1$ integers $s^{*} + (k+1)M$ for $0 \le k < K-1$, where $s^{*} \in [0, M)$ is the least representative, all lie in $[1, B]$ and are distinct. $\square$

> **Lemma 8.3 (Residue sets).** For any $\mathcal{S} \subseteq \mathbb{Z}/M\mathbb{Z}$,
> $$\#\{\,t \in [1,B] : t \bmod M \in \mathcal{S}\,\} \;\ge\; |\mathcal{S}| \cdot \big(\lfloor B/M\rfloor - 1\big).$$

*Proof.* The left side is a disjoint union over $s \in \mathcal{S}$ of the sets counted in Lemma 8.2. $\square$

Combining with the one-bit-per-prime law:

> **Theorem 8.4 (Pinning barrier).** Let $P$ be a finite set of odd primes, $M = \prod_{\ell \in P}\ell$, and $N$ coprime to $M$. Then the number of integers in the window $[1, B]$ whose residue modulo $M$ is a legal trace residue satisfies
> $$\#\{\,t \in [1,B] : t \bmod M \in S_M(N)\,\} \;\ge\; \frac{\left(\prod_{\ell \in P}(\ell-1)\right)\big(\lfloor B/M\rfloor - 1\big)}{2^{|P|}}.$$

*Proof.* Apply Lemma 8.3 with $\mathcal{S} = S_M(N)$ and bound $|S_M(N)| \ge 2^{-|P|}\prod(\ell-1)$ by Theorem 4.5. $\square$

Since $\prod_{\ell \in P}(\ell - 1) = M \prod (1 - 1/\ell)$, the right side is $\asymp B\,2^{-|P|}$ for $B \gg M$. In words: **after applying all the congruence information available modulo $M$, the surviving candidate set still has density about $2^{-\omega(M)}$ in the window.** To reduce $[1, N]$ to a single candidate one needs $2^{|P|} \gtrsim N$, i.e.
$$|P| \;\gtrsim\; \log_2 N,$$
and hence a modulus $M = \prod_{\ell \in P} \ell$ enormously larger than $N$ (by the prime number theorem, $\log M \sim |P|\log|P| \gg \log N$). For $k$-bit factors, the requirement is $M \gg e^{2^{k}}$-scale, wholly out of reach; and in any case, once $M > N$ the residue of $s$ modulo $M$ *is* $s$, so the "attack" presupposes its own output.

A crisp finite-scale version:

> **Proposition 8.5 (Two candidates always survive).** If $3M \le N$ then every residue class modulo $M$ contains at least two integers of $[1,N]$. In particular no modulus $M \le N/3$ can determine the trace.

*Proof.* $\lfloor N/M \rfloor \ge 3$, so Lemma 8.2 gives at least $2$. $\square$

Thus the profile is complete: the trace is the most accessible residue target among symmetric invariants, and it is still unusable. Additive gain against exponential search does not close.

---

## 9. Discussion, and the one thing left open

### 9.1 Summary of the profile

| Quantity | Residues available mod odd $\ell$ | Bits revealed by $N$ | Nature of the visible information |
|---|---|---|---|
| Factor $p$ | all $\ell - 1$ units | $0$ (exactly) | none |
| Trace $s = p + q$ | $(\ell + \chi_\ell(N))/2$ | $1$ per prime, additive | the Legendre symbol $\chi_\ell(N)$ — public |
| Trace, low bits | $s \equiv 3 - N \pmod 4$ | exact identity | a function of $N \bmod 4$ — public |
| Triple sum $x+y+z$ | all $\ell$ for $\ell \ge 11$ | $0$ | none |

The trace is thus the *least hidden symmetric invariant*: the unique place in this table where the public modulus constrains a factor-bearing quantity at all. Yet in each row where information appears, it is information that a reader of $N$ already possessed.

### 9.2 The residual question: size versus set

There is one gap in the picture, and it is where the interesting mathematics now lies. Theorem 5.1 says the *size* of $S_\ell(N)$ sees $N$ only through $\chi_\ell(N)$. But the *set* appears to see everything:

> **Conjecture C1 (Trace set is a complete invariant).** For every odd prime $\ell$ and all $N, N' \in \mathbb{F}_\ell^\times$: $S_\ell(N) = S_\ell(N')$ implies $N = N'$.

This has been verified exhaustively at $\ell = 13$ and computationally for $\ell \le 41$. The heuristic argument uses the discriminant description: $S_\ell(N) = \{s : \chi_\ell(s^2-4N) \ne -1\}$ is the non-residue-avoiding locus of a quadratic pencil, and the overlap
$$|S_\ell(N) \cap S_\ell(N')| = \frac{1}{4}\sum_{s}\big(1 + \chi(s^2-4N)\big)\big(1 + \chi(s^2-4N')\big) + O(1)$$
is $\ell/4 + O(\sqrt{\ell})$ by Weil's bound for $N \ne N'$, whereas $S_\ell(N) = S_\ell(N')$ would force $\ell/2 + O(1)$. For $\ell$ beyond the implied constant this is a contradiction; making the constant explicit would prove C1 for all but finitely many $\ell$, and a finite check would complete it.

The conceptual point of C1 is that it locates exactly the information a residue attack fails to convert. Knowing $|S_\ell(N)|$ is worth one public bit; knowing $S_\ell(N)$ is worth all of $N$ — and $N$ was public to begin with. The chain never touches $p$.

### 9.3 The arity threshold

> **Conjecture C2 (Arity-3 threshold).** For every prime $\ell \ge 11$ and every $N \in \mathbb{F}_\ell^\times$, $\{x+y+z : xyz = N\} = \mathbb{F}_\ell$, and $\ell = 3, 5, 7$ are the only exceptions.

Verified for $\ell \le 19$, with $\ell = 11$ and the exception at $\ell = 5$ established exhaustively. The natural proof route is the genus-$1$ model $w^2 = z^2(s-z)^2 - 4Nz$ of Section 7 together with the Hasse–Weil bound, plus care with the degenerate fibres $z = 0$ and the singular members of the pencil. Proving C2 would turn the arity dichotomy from a numerical observation into a theorem, and would make precise the claim that the trace constraint *is* the quadratic discriminant.

### 9.4 What this is not

It bears repeating: none of the results here constitutes progress toward factoring, and Theorem 8.4 is the proof that they cannot. The value of the profile is the opposite — it is a *negative* result made quantitative. Where security arguments usually say "we know of no efficient algorithm", here one can say, of a specific and maximally favourable target, exactly how much information exists to be exploited ($\omega(M)$ bits), exactly what it consists of (Legendre symbols and $N \bmod 4$), and exactly why it does not accumulate fast enough (density $2^{-\omega}$ against a window of size $N$).

### 9.5 Further directions

Beyond C1 and C2, several questions suggest themselves.

* **Higher symmetric functions.** For $k$ factors, the elementary symmetric functions $e_1, \dots, e_{k-1}$ interpolate between the trace and the full factorisation. Which of them are congruence-constrained, and by how much? Theorem 6.6 handles $e_1$ modulo $4$ for all $k$; the arity dichotomy handles $e_1$ modulo $\ell$ for $k \le 3$. The general picture should be governed by the geometry of the corresponding symmetric-function fibres.
* **Prime-power and composite-square moduli.** Everything here is for squarefree moduli. Modulo $\ell^2$ the trace set should have size $\ell \cdot (\ell + \chi)/2$ by Hensel lifting away from the ramified locus, with corrections at the degenerate traces $s^2 = 4N$; making this exact would complete the multiplicativity picture.
* **The carry sliver.** The pairwise bit matrix attributes part of the $18.5$–$21.9\%$ visible fraction to the top-two-bit carry-out of $p + q$. Quantifying this — for $p, q$ in a known range, how many high bits of $s$ are determined by $N$? — is a question about the distribution of $\sqrt{N}$-sized quantities and should admit a clean answer.
* **Other symmetric witnesses.** Is the trace uniquely the least hidden, or do quantities such as $p^2 + q^2 = s^2 - 2N$ or $|p - q| = \sqrt{s^2-4N}$ carry a different profile? The first is a function of $s$ and $N$, hence carries the same bits; the second is the discriminant itself, and its trace-set analogue is worth computing.

---

## 10. Conclusion

For a semiprime $N = pq$, the factor $p$ is congruence-invisible: modulo every prime, the public residue of $N$ excludes no candidate, and the independence is exact rather than approximate. The trace $s = p+q$, by contrast, is congruence-visible: it is confined modulo each odd prime $\ell$ to a set of size exactly $(\ell + \chi_\ell(N))/2$, the halvings are perfectly multiplicative across primes, and at the prime $2$ the constraint sharpens into the identity $s_1 = 1 - N_1$, sharp because bit $2$ obeys only a $3/4$ law. The visible bit at each odd prime is precisely the Legendre symbol of $N$ — public data — so the constraint distinguishes moduli only through what is already known. The whole effect is an arity-$2$ phenomenon: the three-factor sum set is all of $\mathbb{F}_\ell$ from $\ell = 11$ onwards. And congruence data modulo $M$ leaves $\asymp N 2^{-\omega(M)}$ candidate traces in the search window $[1, N]$, so pinning the trace demands more primes than the modulus has bits.

The trace is the least-hidden symmetric invariant of a semiprime, the most accessible residue target that exists — and it is not a factoring tool. That conjunction, made exact, is the content of this work.
