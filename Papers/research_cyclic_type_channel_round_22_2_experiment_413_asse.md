# The Splitting-Type Channel of a Cyclic Field: Exact Values, CRT Additivity, and the Failure of the One-Bit Cap

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

Let $f$ be a prime and let $\mathbb{Q}(\zeta_f)$ be the $f$-th cyclotomic field, whose Galois group is cyclic of order $n = f-1$. For an unramified prime $p$ the *splitting type* $T(p) = \operatorname{ord}_f(p)$ — the residue degree, equivalently the order of the Frobenius element $p \bmod f$ — is a multi-state random variable taking each divisor $d \mid n$ with rate $\varphi(d)/n$. We study the *type-pair channel* of a semiprime $N = pq$: the mutual information between the visible residue $N \bmod f$ and the unordered pair $\{T(p), T(q)\}$, denoted $I_{\mathrm{pair}}(n)$.

We prove: (i) the single-prime channel is lossless, $I(p \bmod f\,;\,T) = H(T) = \sum_{d \mid n}\frac{\varphi(d)}{n}\log_2\frac{n}{\varphi(d)}$, and is unchanged by refining the modulus (*thickening zero*); (ii) $I_{\mathrm{pair}}$ is **additive over coprime factorisations**, $I_{\mathrm{pair}}(mn) = I_{\mathrm{pair}}(m) + I_{\mathrm{pair}}(n)$ for $\gcd(m,n)=1$, hence $I_{\mathrm{pair}}(n) = \sum_{p \mid n} I_{\mathrm{pair}}(p^{v_p(n)})$; (iii) a closed form for prime orders, $I_{\mathrm{pair}}(p) = \log_2 p - \frac{(p-1)(2p-1)}{p^2}\log_2(p-1) + \frac{(p-1)(p-2)}{p^2}\log_2(p-2)$, from which $I_{\mathrm{pair}}(p) = 1 \iff p = 2$, every odd prime order lies strictly below one bit with envelope $(\log_2 p + 3p)/p^2$, and consequently **any order above one bit is composite**; (iv) exact values $I_{\mathrm{pair}}(4) = 5/4$, $I_{\mathrm{pair}}(6) = \log_2 3 - 1/9$, $I_{\mathrm{pair}}(12) = 5/36 + \log_2 3$, $I_{\mathrm{pair}}(16) = 85/64$, all strictly above the one-bit cap of the binary symmetric fork; (v) infinite above-cap families — $I_{\mathrm{pair}}(4m) \ge 5/4$ for every odd $m$ — and an *odd* above-cap order $M = 300\,840\,735\,195$, refuting the hypothesis that an element of order two is responsible; (vi) a geometric prime-power ladder $I_{\mathrm{pair}}(2^k) = \frac43(1-4^{-k})$ for $k \le 5$ with supremum $4/3$, and the analogous $3$-adic ladder; (vii) strict lossiness of the binary root-count readout, whose entropy is pinned to the binary entropies $H(1/4)$ and $H(1/6)$, and of the split-count projection, which recovers only $\approx 0.2947$ of the $1.25$ bits at $n = 4$. Finally we show the *which-factor wall is exactly zero*: the unordered pair channel coincides with the ordered one, so the leakage is entirely symmetric and gives no purchase on separating the factors.

**Keywords:** cyclotomic field, splitting type, residue degree, Frobenius, mutual information, Euler totient, Chinese Remainder Theorem, semiprime.

---

## 1. Introduction

### 1.1 The problem

A recurring theme in the information-theoretic study of semiprimes is the following. Fix an arithmetic invariant $\chi$ of a prime, form a semiprime $N = pq$, and ask how many bits the visible quantity $N$ (or $N$ modulo some fixed base) reveals about the *pair* $(\chi(p), \chi(q))$. When $\chi$ is binary — "is $p$ a quadratic residue?", "is $p \equiv 1 \bmod 4$?" — the answer is bounded by one bit, and in the symmetric case (where the unordered pair is all that can be observed) the bound is attained. This *one-bit binary-fork cap* has been the standing ceiling for symmetric semiprime channels.

The observation driving this paper is that the cap is a property of *binary* invariants, not of semiprimes and not of symmetry. There is a canonical, arithmetically complete, *multi-state* invariant attached to a prime in a cyclic field: its splitting type. We compute its semiprime pair channel exactly and find that the cap fails, quantitatively and structurally.

### 1.2 Setting

Let $f$ be a prime, $\zeta_f$ a primitive $f$-th root of unity, and $K = \mathbb{Q}(\zeta_f)$. Then $\operatorname{Gal}(K/\mathbb{Q}) \cong (\mathbb{Z}/f)^\times$, a cyclic group of order $n = f - 1$. For a prime $p \ne f$ the Frobenius conjugacy class is the singleton $\{p \bmod f\}$, and the factorisation of $p$ in the ring of integers of $K$ is
$$p\mathcal{O}_K = \mathfrak{p}_1 \cdots \mathfrak{p}_{g}, \qquad g = \frac{n}{T(p)}, \qquad T(p) := \operatorname{ord}_f(p),$$
with each $\mathfrak{p}_i$ of residue degree $T(p)$. Thus $T(p)$ is the *complete splitting type*: it determines the entire factorisation shape, and no coarser invariant does.

Because $T(p)$ depends only on $p \bmod f$, and because the residues $p \bmod f$ equidistribute over $(\mathbb{Z}/f)^\times$ (Dirichlet; Chebotarev in general), the correct probabilistic model is a *finite counting model*: choose the Frobenius exponent uniformly from $\mathbb{Z}/n$ and read off the type. All results below are exact statements about that finite model.

### 1.3 Contributions

1. A general finite-counting entropy framework with the structural facts needed: the Shannon form, non-negativity, the $\log_2|S|$ cap, the data-processing inequality for deterministic coarsenings, additivity over independent products, and invariance under injective recodings and relabellings.
2. The group-theoretic grounding: the exponent model is faithful (a generator exists and $\operatorname{ord}(g^a) = n/\gcd(a,n)$), and the exact type-count law $\#\{a : T(a) = d\} = \varphi(d)$.
3. The exact single-prime results: losslessness, thickening zero, the totient entropy law.
4. The exact type-pair channel: closed-form values, CRT additivity, the prime formula, prime-power ladders, infinite above-cap families, an odd above-cap order.
5. Lossiness of the two standard coarsenings (root count, split count), quantified exactly.
6. The vanishing of the which-factor wall.

---

## 2. The counting-entropy framework

Throughout, $S$ is a finite nonempty set, and a *readout* is any function $g : S \to B$ into a set with decidable equality. All entropies are in bits.

**Definition 2.1 (Counting entropy).** For a readout $g$ on $S$,
$$H_S(g) \;=\; \log_2 |S| \;-\; \frac{1}{|S|}\sum_{a \in S} \log_2 \big|g^{-1}(g(a))\big| .$$

This *fibre-average* form is chosen because it is manifestly computable by enumeration; it is equivalent to the usual Shannon entropy of the pushforward of the uniform measure.

**Proposition 2.2 (Shannon form).** $H_S(g) = -\sum_{v \in g(S)} \pi_v \log_2 \pi_v$, where $\pi_v = |g^{-1}(v)|/|S|$.

*Proof sketch.* Group the sum over $a \in S$ by the value $v = g(a)$; each fibre contributes $|g^{-1}(v)|\log_2|g^{-1}(v)|$. Divide by $|S|$, use $\sum_v \pi_v = 1$ and $\log_2 \pi_v = \log_2|g^{-1}(v)| - \log_2 |S|$. $\square$

**Definition 2.3 (Conditional entropy, mutual information).** For readouts $g : S \to B$ and $k : S \to C$,
$$H_S(g \mid k) = \sum_{c \in k(S)} \frac{|k^{-1}(c)|}{|S|}\, H_{k^{-1}(c)}(g), \qquad I_S(g\,;\,k) = H_S(g) - H_S(g\mid k).$$

**Proposition 2.4 (Basic structure).** (a) $H_S(g) \ge 0$; (b) $H_S(g) \le \log_2|S|$; (c) *data processing*: for any $h$, $H_S(h \circ g) \le H_S(g)$ and $H_S(h\circ g \mid k) \le H_S(g \mid k)$; (d) $I_S(g;k) \ge 0$; (e) if $k$ is injective on $S$ then $H_S(g \mid k) = 0$, hence $I_S(g;k) = H_S(g)$.

*Proof sketch.* (a) and (b) follow from $1 \le |g^{-1}(g(a))| \le |S|$ termwise. (c) each fibre of $h \circ g$ is a union of fibres of $g$, so $|g^{-1}(g(a))| \le |(h\circ g)^{-1}(h(g(a)))|$, and the entropy is a *decreasing* function of fibre sizes; the conditional version is the same inequality applied on each fibre of $k$ and averaged with non-negative weights. (d) is the concavity/Jensen step, or equivalently the fibre-refinement argument: conditioning refines fibres, which can only decrease the fibre-average term. (e) each fibre of an injective $k$ is a singleton, which carries zero entropy. $\square$

**Proposition 2.5 (Product additivity).** If $S = S_1 \times S_2$, $g = (g_1, g_2)$ and $k = (k_1, k_2)$ act coordinatewise, then
$$H_S(g) = H_{S_1}(g_1) + H_{S_2}(g_2), \quad H_S(g\mid k) = H_{S_1}(g_1 \mid k_1) + H_{S_2}(g_2\mid k_2), \quad I_S(g;k) = I_{S_1}(g_1;k_1) + I_{S_2}(g_2;k_2).$$

*Proof sketch.* The fibre of a coordinatewise readout over a product is the product of the fibres, so $\log_2$ of its cardinality splits as a sum, and the average over $S$ splits as the sum of the averages. For the conditional statement, the fibres of $k$ over the product are products of the fibres of $k_1$ and $k_2$; apply the unconditional statement inside each and note that the weights factor. $\square$

**Proposition 2.6 (Invariance).** $H$, $H(\cdot\mid\cdot)$ and $I$ are unchanged by (i) replacing a readout by an injective recoding of it, (ii) relabelling $S$ along a bijection compatible with the readouts.

These invariances are what make it legitimate to move freely between the exponent model, the residue model, and product decompositions.

---

## 3. The splitting type as a finite object

**Definition 3.1 (Splitting type).** For $n \ge 1$ and $a \in \mathbb{Z}$, set
$$T_n(a) = \frac{n}{\gcd(a,n)}.$$

**Proposition 3.2 (Faithfulness of the exponent model).** Let $f$ be prime, $n = f-1$. There is a generator $g$ of $(\mathbb{Z}/f)^\times$ with $\operatorname{ord}(g) = n$ such that every unit $u$ is $g^a$ for a unique $a < n$, and $\operatorname{ord}(u) = T_n(a)$.

*Proof sketch.* $(\mathbb{Z}/f)^\times$ is cyclic of order $n$; pick a generator. In any finite group $\operatorname{ord}(g^a) = \operatorname{ord}(g)/\gcd(a, \operatorname{ord}(g))$, which is exactly $T_n(a)$. Reduce the exponent mod $n$; $T_n$ is invariant under $a \mapsto a \bmod n$. $\square$

**Proposition 3.3 (Type-count law).** For $n > 0$ and $d \mid n$, $\#\{a \in \mathbb{Z}/n : T_n(a) = d\} = \varphi(d)$, and the set of realised types is exactly the divisor set of $n$.

*Proof sketch.* $T_n(a) = d$ iff $\gcd(a,n) = n/d$, iff $a = (n/d)b$ with $\gcd(b,d) = 1$ and $b < d$; there are $\varphi(d)$ such $b$. Surjectivity onto the divisors is witnessed by $a = n/d$. $\square$

**Definition 3.4 (Type entropy).** $H(T) := H_{\mathbb{Z}/n}(T_n)$.

**Theorem 3.5 (Euler-totient entropy law).** For $n > 0$,
$$H(T) \;=\; \sum_{d \mid n} \frac{\varphi(d)}{n}\,\log_2\frac{n}{\varphi(d)}.$$

*Proof sketch.* Combine Proposition 2.2 with Proposition 3.3: the fibre over $d$ has size $\varphi(d)$ and the rate is $\varphi(d)/n$. $\square$

Sample values: $H(T) = 1$ at $n=2$; $3/2$ at $n=4$ (rates $\tfrac14,\tfrac14,\tfrac12$ on types $1,2,4$); $\tfrac13 + \log_2 3 \approx 1.9183$ at $n = 6$ (rates $\tfrac16,\tfrac16,\tfrac13,\tfrac13$ on $1,2,3,6$); $7/4$ at $n = 8$; $\approx 2.4183$ at $n=12$; $15/8$ at $n=16$.

**Theorem 3.6 (Losslessness).** $I(a\,;\,T_n) = H(T)$: the residue determines the type exactly.

*Proof sketch.* The conditioning variable is the identity on $\mathbb{Z}/n$, which is injective, so the conditional entropy vanishes by Proposition 2.4(e). $\square$

**Theorem 3.7 (Thickening zero).** For any readout $w$ that is injective on $\mathbb{Z}/n$ — in particular $a \mapsto a \bmod nm$ for any $m$, i.e. observing $p$ modulo $f^2$ or any multiple of $f$ — one has $I(w\,;\,T_n) = H(T)$. Moreover $T_n$ itself is invariant under thickening: $T_n(a \bmod nm) = T_n(a)$.

*Proof sketch.* Same injectivity argument; the invariance is $\gcd(a \bmod nm, n) = \gcd(a,n)$, which holds because $n \mid nm$. $\square$

So the type channel is *saturated at a single residue layer*: there is nothing further to learn from a finer modulus, and nothing is lost by working with $p \bmod f$ alone.

---

## 4. Coarsenings and their exact losses

Two coarsenings of the type appear naturally in the literature.

**Definition 4.1 (Root-count readout).** $\mathrm{nr}_n(T) = n$ if $T = 1$, and $0$ otherwise. Equivalently: the binary flag "$p$ splits completely".

**Definition 4.2 (Split-count projection).** For an unordered type pair $\{t_1,t_2\}$, $s = [t_1 = 1] + [t_2=1] \in \{0,1,2\}$: how many of the two factors split completely.

By data processing (Proposition 2.4(c)), both readouts carry at most as much as the type. The point is that the inequality is *strict*, with exactly computable defect.

**Theorem 4.3 (Root-count entropies, and quartic pinning).**
$$H(\mathrm{nr}_4) = 2 - \tfrac34\log_2 3 = H(1/4) \approx 0.8113, \qquad H(\mathrm{nr}_6) = 1 + \log_2 3 - \tfrac56\log_2 5 = H(1/6) \approx 0.6500,$$
where $H(x) = -x\log_2 x - (1-x)\log_2(1-x)$. Both are strictly below the corresponding type entropies $3/2$ and $\tfrac13 + \log_2 3$.

*Proof sketch.* The readout is binary with rates $(\varphi(1)/n, 1 - \varphi(1)/n) = (1/n, 1-1/n)$, since exactly one exponent, $a = 0$, has type $1$. So $H(\mathrm{nr}_n) = H(1/n)$ identically; the displayed closed forms are $H(1/4)$ and $H(1/6)$ expanded. Strictness follows from $\log_2 3 > 19/12$ and $\log_2 5 > 23/10$, elementary integer inequalities ($3^{12} > 2^{19}$, $5^{10} > 2^{23}$). $\square$

The $n=4$ instance is the *prime-level quartic pinning*: the completeness flag for a quartic residue condition has entropy exactly $H(1/4)$, not approximately.

The moral is that $\mathrm{nr}$ collapses the multi-state type into two states (at $n = 4$ it merges types $2$ and $4$; at $n = 6$ it merges $2$, $3$ and $6$), and the merge is lossy by a definite amount: $0.69$ bits at $n = 4$, $1.27$ bits at $n = 6$.

---

## 5. The type-pair channel

**Definition 5.1 (The box, the pair, the residue).** Let $B_n = (\mathbb{Z}/n) \times (\mathbb{Z}/n)$ be the set of exponent pairs $(a,b)$ of the two prime factors, uniformly distributed. Define
$$\mathrm{tp}_n(a,b) = \{T_n(a), T_n(b)\} \quad (\text{unordered}), \qquad \rho_n(a,b) = a + b \bmod n .$$
The second is the exponent of the visible semiprime $N = pq$, since Frobenius exponents add under multiplication.

**Definition 5.2 (The type-pair channel).**
$$I_{\mathrm{pair}}(n) \;=\; I_{B_n}\big(\mathrm{tp}_n\,;\,\rho_n\big) \;=\; H\big(\mathrm{tp}_n\big) - H\big(\mathrm{tp}_n \mid \rho_n\big).$$

Equivalently, in the enumerative form used for all exact evaluations,
$$I_{\mathrm{pair}}(n) = H(\Pi) - \frac{1}{n}\sum_{c \in \mathbb{Z}/n} H(\Pi_c),$$
where $\Pi$ is the law of the unordered pair and $\Pi_c$ its law conditioned on $a + b \equiv c$. (Each residue class $c$ has exactly $n$ preimages in the box, so the conditional weights are uniform.)

**Definition 5.3 (Split-count channel).** $I_s(n) = I_{B_n}(s \circ \mathrm{tp}_n\,;\,\rho_n)$, the channel of the classical split-count readout.

### 5.1 The which-factor wall

**Theorem 5.4 (Symmetrisation is free).** Let $\sigma$ be the swap involution on $B_n$. Since $\mathrm{tp}_n$ is symmetric and $\rho_n$ is symmetric, the entropy defect of forgetting the order of the ordered type pair is the same with and without conditioning on $\rho_n$, and therefore
$$I_{\mathrm{pair}}(n) \;=\; I_{B_n}\big((T_n(a), T_n(b))\,;\,\rho_n\big),$$
the *ordered* pair channel. Equivalently, the which-factor wall is exactly $0$.

*Proof sketch.* The unordered fibre over $\{t_1,t_2\}$ with $t_1 \ne t_2$ is the disjoint union of the ordered fibre over $(t_1,t_2)$ and its $\sigma$-image, which has the same cardinality; diagonal fibres are unchanged. Hence the fibre-average term of $H$ differs from that of the ordered readout by exactly the off-diagonal mass times $1$ bit. Since $\rho_n \circ \sigma = \rho_n$, the same computation applies verbatim inside each fibre of $\rho_n$, and the two defects cancel in the difference defining $I$. $\square$

This has two consequences. Practically, no amount of type information distinguishes $p$ from $q$: the leaked bits are symmetric functions. Technically, it allows all subsequent arguments to be conducted with the ordered pair, which is a coordinatewise readout — the essential hypothesis for product additivity.

### 5.2 Exact values

All values below are exact identities obtained by finite enumeration of the box $B_n$ and its conditional slices, followed by evaluation of the resulting integer-count entropy sums.

**Theorem 5.5 (Exact table).**

| $n$ | $H(T)$ | $H(\mathrm{tp})$ | $H(\mathrm{tp}\mid\rho)$ | $I_{\mathrm{pair}}(n)$ | numeric |
|---|---|---|---|---|---|
| $2$ | $1$ | $3/2$ | $1/2$ | $1$ | $1.0000$ |
| $3$ | $\log_2 3 - \tfrac23$ | $2\log_2 3 - \tfrac{16}{9}$ | $\log_2 3 - \tfrac23$ | $\log_2 3 - \tfrac{10}{9}$ | $0.4739$ |
| $4$ | $3/2$ | $19/8$ | $9/8$ | $5/4$ | $1.2500$ |
| $5$ | $\log_2 5 - \tfrac85$ | $2\log_2 5 - \tfrac{88}{25}$ | $\log_2 5 - \tfrac{12}{25}\log_2 3 - \tfrac{16}{25}$ | $\log_2 5 + \tfrac{12}{25}\log_2 3 - \tfrac{72}{25}$ | $0.2027$ |
| $6$ | $\log_2 3 + \tfrac13$ | — | — | $\log_2 3 - \tfrac19$ | $1.4739$ |
| $8$ | $7/4$ | $91/32$ | $49/32$ | $21/16$ | $1.3125$ |
| $9$ | $\tfrac43\log_2 3 - \tfrac89$ | $\tfrac83\log_2 3 - \tfrac{184}{81}$ | $\tfrac{14}{9}\log_2 3 - \tfrac{28}{27}$ | $\tfrac{10}{9}\log_2 3 - \tfrac{100}{81}$ | $0.5265$ |
| $10$ | $1.7219$ | — | — | $\log_2 5 + \tfrac{12}{25}\log_2 3 - \tfrac{47}{25}$ | $1.2027$ |
| $12$ | $2.4183$ | — | — | $\log_2 3 + \tfrac{5}{36}$ | $1.7239$ |
| $15$ | $\log_2 3 + \log_2 5 - \tfrac{34}{15}$ | — | — | $\tfrac{37}{25}\log_2 3 + \log_2 5 - \tfrac{898}{225}$ | $0.6766$ |
| $16$ | $15/8$ | — | — | $85/64$ | $1.3281$ |
| $27$ | $1.3264$ | — | — | $\tfrac{91}{81}\log_2 3 - \tfrac{910}{729}$ | $0.5324$ |
| $32$ | $31/16$ | — | — | $341/256$ | $1.3320$ |

**Corollary 5.6 (Failure of the one-bit cap).** $I_{\mathrm{pair}}(n) > 1$ for $n \in \{4,6,8,10,12,14,16,18,20,32\}$, while $I_{\mathrm{pair}}(2) = 1$ exactly and $I_{\mathrm{pair}}(n) < 1$ for $n \in \{3,5,7,9,11,13,15,27\}$.

*Proof sketch.* Substitute the closed forms and use certified rational bounds on the logarithms: $\tfrac{19}{12} < \log_2 3 < \tfrac{27}{17}$ (from $3^{12} > 2^{19}$ and $3^{17} < 2^{27}$), $\tfrac{23}{10} < \log_2 5 < \tfrac73$, $\tfrac{14}{5} < \log_2 7 < 3$, $\log_2 11 < \tfrac72$, $\log_2 13 < \tfrac{15}{4}$. Each comparison then reduces to a linear inequality over $\mathbb{Q}$. $\square$

**Remark 5.7 (Divisor richness, not size).** Among the computed orders, the maximum is attained at $n = 12$: $I_{\mathrm{pair}}(12) > I_{\mathrm{pair}}(m)$ for $m \in \{2,4,6,10,16\}$. The order $12$ has six divisors, hence six type states, whereas $16$ has only five; richness of the divisor lattice, not the magnitude of $n$, governs the channel.

### 5.3 CRT additivity

This is the structural heart of the paper.

**Theorem 5.8 (Multiplicativity of the type).** If $\gcd(m,n) = 1$ then $T_{mn}(a) = T_m(a)\,T_n(a)$ for all $a$.

*Proof sketch.* $\gcd(a, mn) = \gcd(a,m)\gcd(a,n)$ for coprime $m, n$, and division distributes: $\frac{mn}{\gcd(a,m)\gcd(a,n)} = \frac{m}{\gcd(a,m)}\cdot\frac{n}{\gcd(a,n)}$. $\square$

**Lemma 5.9 (Unique coprime splitting).** If $x, x' \mid m$, $y, y' \mid n$, $\gcd(m,n)=1$ and $xy = x'y'$, then $x = x'$ and $y = y'$.

*Proof sketch.* $\gcd(xy, m) = x$ because $y$ is coprime to $m$ and $x \mid m$; likewise $\gcd(x'y', m) = x'$. $\square$

Thus the factorisation of a type into its $m$- and $n$-parts is recoverable: the map $d \mapsto (\gcd(d,m), \gcd(d,n))$ inverts multiplication on the relevant divisor sets, so passing between $T_{mn}$ and the pair $(T_m, T_n)$ is an *injective recoding* in the sense of Proposition 2.6.

**Theorem 5.10 (CRT additivity).** For $m, n > 0$ coprime,
$$I_{\mathrm{pair}}(mn) = I_{\mathrm{pair}}(m) + I_{\mathrm{pair}}(n).$$

*Proof sketch.* Four steps.
1. By Theorem 5.4 we may work with the ordered pair channel.
2. The Chinese Remainder map $(a,b) \mapsto \big((a \bmod m, b \bmod m), (a \bmod n, b \bmod n)\big)$ is a bijection $B_{mn} \to B_m \times B_n$: injectivity is the CRT congruence criterion, surjectivity follows by cardinality since $|B_{mn}| = (mn)^2 = |B_m||B_n|$.
3. Under this bijection, the ordered type readout becomes the coordinatewise readout $(T_m$-pair, $T_n$-pair$)$, by Theorem 5.8 and the injective recoding of Lemma 5.9; and the residue readout becomes the coordinatewise pair of residues, since $(a+b) \bmod m$ and $(a+b)\bmod n$ determine and are determined by $(a+b) \bmod mn$.
4. Apply relabelling invariance (Proposition 2.6) and product additivity (Proposition 2.5). $\square$

**Corollary 5.11 (Prime-power decomposition).** For $n \ne 0$,
$$I_{\mathrm{pair}}(n) \;=\; \sum_{p \mid n} I_{\mathrm{pair}}\!\left(p^{\,v_p(n)}\right),$$
and $I_{\mathrm{pair}}(1) = 0$.

**Corollary 5.12 (Doubling law).** For odd $m > 0$, $I_{\mathrm{pair}}(2m) = I_{\mathrm{pair}}(m) + 1$.

Instances: $I_{\mathrm{pair}}(6) = I_{\mathrm{pair}}(3)+1$, $I_{\mathrm{pair}}(10) = I_{\mathrm{pair}}(5)+1$, $I_{\mathrm{pair}}(14) = I_{\mathrm{pair}}(7)+1$, $I_{\mathrm{pair}}(18) = I_{\mathrm{pair}}(9)+1$; and coprime instances $I_{\mathrm{pair}}(12) = I_{\mathrm{pair}}(4)+I_{\mathrm{pair}}(3)$, $I_{\mathrm{pair}}(15) = I_{\mathrm{pair}}(3)+I_{\mathrm{pair}}(5)$, $I_{\mathrm{pair}}(20) = I_{\mathrm{pair}}(4)+I_{\mathrm{pair}}(5)$.

### 5.4 The prime orders

**Theorem 5.13 (Prime closed form).** For every prime $p$,
$$I_{\mathrm{pair}}(p) \;=\; \log_2 p \;-\; \frac{(p-1)(2p-1)}{p^2}\log_2(p-1) \;+\; \frac{(p-1)(p-2)}{p^2}\log_2(p-2),$$
with the convention $0\log_2 0 = 0$ (relevant only at $p = 2$, where the formula gives $1$).

*Proof sketch.* With $n = p$ prime, $T_p(a) = 1$ if $a = 0$ and $T_p(a) = p$ otherwise. Hence the unordered pair takes three values with fibre sizes
$$\big|\{(1,1)\}\big| = 1, \qquad \big|\{(1,p)\}\big| = 2(p-1), \qquad \big|\{(p,p)\}\big| = (p-1)^2,$$
in a box of size $p^2$; this gives the unconditional entropy
$$H(\mathrm{tp}) = 2\log_2 p - \frac{2(p-1)}{p^2} - \frac{2(p-1)\log_2(p-1)}{p}.$$
For the conditional entropy, each residue class $c$ has exactly $p$ preimages, forming a diagonal $\{(a, c-a)\}$. On the class $c = 0$ the diagonal contains $(0,0)$ and $p-1$ pairs with both coordinates nonzero, so the pair distribution is $(1, 0, p-1)$ over the three values. On each class $c \ne 0$ the diagonal contains exactly two pairs with a zero coordinate, namely $(0,c)$ and $(c,0)$, and $p-2$ pairs with both nonzero, giving the distribution $(0, 2, p-2)$. Averaging the resulting entropies over the $p$ classes with equal weights and subtracting from $H(\mathrm{tp})$ yields, after clearing denominators, the displayed expression. $\square$

**Theorem 5.14 (Odd prime orders lie below the cap).** For every prime $p \ne 2$, $I_{\mathrm{pair}}(p) < 1$; consequently $I_{\mathrm{pair}}(p) = 1$ if and only if $p = 2$.

*Proof sketch.* Write the formula as $\log_2 p - \frac{(p-1)^2}{p^2}\big[\log_2(p-1) - \log_2(p-2)\big] - \frac{p-1}{p^2}\big[p\log_2(p-1)\big] + \text{(small terms)}$ and use the elementary increment bound $\log_2(x+1) - \log_2 x \le \frac{1}{x\ln 2}$ together with $\log_2 p \le p$. The dominant cancellation is $\log_2 p$ against $\frac{(p-1)(2p-1)}{p^2}\log_2(p-1) - \frac{(p-1)(p-2)}{p^2}\log_2(p-2)$, whose leading term is also $\log_2 p$; what survives is $O(1/p)$ and is bounded by $1$ already at $p = 3$. $\square$

**Theorem 5.15 (Decay envelope).** For every odd prime $p$, $\displaystyle I_{\mathrm{pair}}(p) \le \frac{\log_2 p + 3p}{p^2}$; in particular $I_{\mathrm{pair}}(p) \to 0$.

**Theorem 5.16 (Above the cap implies composite).** If $I_{\mathrm{pair}}(n) > 1$ then $n$ is not prime.

*Proof sketch.* Immediate from Theorems 5.14 and $I_{\mathrm{pair}}(2)=1$. $\square$

So the above-cap phenomenon is intrinsically *compositional*: it arises only by summing the contributions of several primary parts, exactly as CRT additivity predicts.

### 5.5 Infinite families

**Theorem 5.17 (Non-negativity).** $I_{\mathrm{pair}}(n) \ge 0$ for all $n$.

**Theorem 5.18 (Above-cap families).** For every odd $m > 0$:
$$I_{\mathrm{pair}}(2m) \ge 1, \qquad I_{\mathrm{pair}}(4m) \ge \tfrac54, \qquad I_{\mathrm{pair}}(8m) \ge \tfrac{21}{16}, \qquad I_{\mathrm{pair}}(16m) \ge \tfrac{85}{64}.$$
In particular $I_{\mathrm{pair}}(4m) > 1$ for every odd $m$: an infinite family of symmetric semiprime forks strictly above the binary cap.

*Proof sketch.* $2^j$ is coprime to every odd $m$; apply Theorem 5.10 and drop the non-negative term $I_{\mathrm{pair}}(m)$. $\square$

**Corollary 5.19 (Unboundedness).** For every bound $B$ there is $n > B$ with $I_{\mathrm{pair}}(n) > 1$ — take $n = 4(2B+1)$. No finite computation could have decided the question.

**Theorem 5.20 (An odd order above the cap).** The odd number
$$M = 9 \cdot 5 \cdot 7\cdot 11\cdot 13\cdot 17\cdot 19\cdot 23\cdot 29\cdot 31 = 300\,840\,735\,195$$
satisfies $I_{\mathrm{pair}}(M) > 1$.

*Proof sketch.* Repeated CRT additivity splits $I_{\mathrm{pair}}(M)$ into the ten primary contributions $I_{\mathrm{pair}}(9), I_{\mathrm{pair}}(5), \dots, I_{\mathrm{pair}}(31)$. Each is bounded below by an explicit rational obtained from the closed forms with certified rational lower bounds on the relevant logarithms; e.g. $I_{\mathrm{pair}}(9) \ge \tfrac{21835}{41472} \approx 0.5265$, $I_{\mathrm{pair}}(5) \ge \tfrac{10371}{51200} \approx 0.2026$, $I_{\mathrm{pair}}(7) \ge \tfrac{2845}{25088} \approx 0.1134$. Their sum exceeds $1$. $\square$

This refutes the natural conjecture that an element of order two (equivalently, evenness of the cyclic order, equivalently the presence of a quadratic subfield) is what breaks the cap. **Evenness is sufficient but not necessary.** What matters is accumulating enough independent primary parts.

### 5.6 The prime-power ladders

**Theorem 5.21 (2-adic ladder).** For $1 \le k \le 5$,
$$I_{\mathrm{pair}}(2^k) = \frac{4}{3}\left(1 - 4^{-k}\right) = \frac{4^k - 1}{3 \cdot 4^{k-1}},$$
giving $1, \tfrac54, \tfrac{21}{16}, \tfrac{85}{64}, \tfrac{341}{256}$; the increments are exactly $I_{\mathrm{pair}}(2^{k+1}) - I_{\mathrm{pair}}(2^k) = 4^{-k}$; the sequence is strictly increasing and bounded above by $4/3$.

**Theorem 5.22 (3-adic ladder).** For $1 \le k \le 3$,
$$I_{\mathrm{pair}}(3^k) = \left(1 - 9^{-k}\right)\cdot\frac{9}{8}\cdot I_{\mathrm{pair}}(3), \qquad I_{\mathrm{pair}}(3^{k+1}) - I_{\mathrm{pair}}(3^k) = 9^{-k}\,I_{\mathrm{pair}}(3) \ \ (k \le 2).$$
In particular $I_{\mathrm{pair}}(27) = \tfrac{91}{81}\log_2 3 - \tfrac{910}{729} \approx 0.5324 < 1$: odd prime-power orders remain below the cap.

Both ladders match the shape
$$I_{\mathrm{pair}}(p^k) = \left(1 - p^{-2k}\right)\frac{p^2}{p^2-1}\,I_{\mathrm{pair}}(p),$$
which we conjecture in general (Section 8). The mechanism is $p$-adic self-similarity: in the box $(\mathbb{Z}/p^k)^2$ the type of $a$ is $p^{\,k - v(a)}$ where $v$ is the $p$-adic valuation; off the diagonal $v(a+b) = \min(v(a), v(b))$; and the conditional law at each valuation level is a rescaled copy of the $p^{k-1}$ law. The geometric factor $1 - p^{-2k}$ is exactly the sum of the self-similar series.

### 5.7 The split-count is one face

**Theorem 5.23 (Split-count channel).**
$$I_s(4) = \tfrac{19}{8} - \tfrac{21}{16}\log_2 3 \approx 0.2947, \qquad I_s(6) = \tfrac{19}{9} + \log_2 3 - \tfrac{55}{36}\log_2 5 \approx 0.1487,$$
and $I_s(n) < I_{\mathrm{pair}}(n)$ for $n = 4, 6$.

*Proof sketch.* The $s$-projection is a deterministic coarsening of the unordered type pair, so data processing gives $\le$; the strictness follows by substituting the exact values and the rational logarithm bounds. The values themselves come from enumerating the three-state readout $s \in \{0,1,2\}$ over the box and over each residue slice: at $n = 4$ the unconditional entropy is $\tfrac{29}{8} - \tfrac32\log_2 3$ and the conditional entropy is $\tfrac54 - \tfrac{3}{16}\log_2 3$. $\square$

**Corollary 5.24 (Binary readouts obey the cap, the type does not).** At $n = 4$: the root-count entropy is $\approx 0.811 < 1$, the split-count channel is $\approx 0.295 < 1$, but the type-pair channel is $5/4 > 1$. The one-bit ceiling is a feature of binary readouts, not of the symmetric semiprime fork itself.

---

## 6. Algorithms

Everything above is finitely computable, and the algorithms are worth stating because they are what makes the exact table possible.

### 6.1 Exact channel by box enumeration

**Input:** cyclic order $n$. **Output:** $I_{\mathrm{pair}}(n)$ as an exact real (a rational combination of $1$ and logarithms of integers).

1. Precompute $T(a) = n/\gcd(a,n)$ for $a = 0,\dots,n-1$. Cost $O(n\log n)$.
2. For each $(a,b) \in (\mathbb{Z}/n)^2$, form the unordered pair $\tau = (\min, \max)$ of types and the class $c = (a+b) \bmod n$. Increment the joint counter $\Pi[\tau]$ and the conditional counter $\Pi_c[\tau]$. Cost $O(n^2)$.
3. $H(\Pi) = \log_2(n^2) - \frac{1}{n^2}\sum_\tau \Pi[\tau]\log_2 \Pi[\tau]$; each slice has total mass exactly $n$, so $H(\Pi_c) = \log_2 n - \frac1n\sum_\tau \Pi_c[\tau]\log_2\Pi_c[\tau]$.
4. Return $H(\Pi) - \frac1n\sum_c H(\Pi_c)$.

Because all counts are integers, the result is a $\mathbb{Q}$-linear combination of $\log_2$ of integers, which can be reduced to a $\mathbb{Q}$-basis $\{1, \log_2 3, \log_2 5, \log_2 7, \dots\}$ by factoring the counts. This is exactly how the closed forms in Theorem 5.5 were produced and certified.

### 6.2 Fast channel by CRT reduction

The $O(n^2)$ cost is prohibitive for large $n$, but Corollary 5.11 makes it unnecessary:

1. Factor $n = \prod p_i^{k_i}$.
2. For each $i$: if $k_i = 1$, use the closed form of Theorem 5.13 ($O(1)$); otherwise enumerate the box of size $p_i^{2k_i}$, or use the conjectural ladder of Section 5.6.
3. Return the sum.

For squarefree $n$ this reduces the cost from $O(n^2)$ to the cost of factoring $n$ plus $O(\omega(n))$ arithmetic. The pair $(n, I_{\mathrm{pair}}(n))$ for $n$ with, say, ten prime factors becomes a one-line computation — this is what makes Theorem 5.20 checkable at all, since a direct enumeration for $M \approx 3\times10^{11}$ would require $\approx 9 \times 10^{22}$ box entries.

### 6.3 Certified logarithm bounds

To decide inequalities such as $I_{\mathrm{pair}}(6) > 1$ rigorously one needs rational enclosures of $\log_2 q$. The recipe is elementary: $2^A \le q^B$ certifies $\frac{A}{B} \le \log_2 q$, and $q^B \le 2^A$ certifies $\log_2 q \le \frac{A}{B}$; each is a single integer comparison. Using $3^{12} = 531441 > 524288 = 2^{19}$ and $3^{17} < 2^{27}$ pins $\log_2 3 \in (\tfrac{19}{12}, \tfrac{27}{17})$, which suffices for every inequality in this paper. Sharper enclosures (e.g. $\log_2 3 \ge 6492/4096$) are obtained by taking $B = 4096$ and $A = \lfloor B\log_2 q\rfloor$.

---

## 7. Discussion and applications

**7.1 What the channel is and is not.** The type-pair channel quantifies structural leakage: how much the residue of a semiprime constrains the joint splitting behaviour of its factors. It is a statement about the *ensemble* of semiprimes with a given visible residue, not about any individual factorisation. The which-factor wall (Theorem 5.4) makes this precise: all the leaked information is invariant under swapping $p$ and $q$, so it can never, by itself, separate them. Moreover, predicting which type pair actually occurs requires the two exponents separately, i.e. requires the factorisation. Consequently these results do not weaken any factoring-based assumption; they refine the picture of what is publicly determined.

**7.2 Why the cap failed.** The classical cap comes from a two-state readout in a symmetric fork: with two states there is one bit to distribute, and symmetry means the pair carries $\log_2 3$ bits of which $1$ can correlate with the sum. Nothing about that argument survives when the readout is multi-state. Rather than a single number, one has a divisor lattice; the correct invariant is not "how many states" but "how the divisor lattice interacts with addition modulo $n$". Corollary 5.11 makes this concrete: the channel is a sum over the primary parts, and each even primary part $\ge 4$ already contributes more than the quadratic $1$ bit could.

**7.3 The role of the divisor lattice.** Two comparisons in Theorem 5.5 are instructive: $I_{\mathrm{pair}}(12) \approx 1.7239 > I_{\mathrm{pair}}(16) \approx 1.3281$ although $12 < 16$, and $I_{\mathrm{pair}}(10) \approx 1.2027 < I_{\mathrm{pair}}(6) \approx 1.4739$ although $10 > 6$. Additivity explains both: $I_{\mathrm{pair}}(12) = \tfrac54 + I_{\mathrm{pair}}(3)$ while $I_{\mathrm{pair}}(16) = \tfrac{85}{64}$, and $I_{\mathrm{pair}}(3) \approx 0.474 > 0.203 \approx I_{\mathrm{pair}}(5)$ because the prime channel decays like $1/p$. So the channel is large when $n$ has many *small* primary parts, and the $2$-adic part is uniquely valuable — it alone can contribute up to $4/3$.

**7.4 Structural readings.** The Euler-totient entropy law (Theorem 3.5) says the type is distributed exactly as the "order" statistic of a uniform element of a cyclic group; thickening zero (Theorem 3.7) says this statistic is a genuine mod-$f$ invariant with no deeper $f$-adic content; the root-count pinning (Theorem 4.3) identifies the classical completeness flag as a *coarsening* whose entropy is exactly $H(1/n)$. Together these say the splitting type is the *complete* object at this level, and the familiar binary invariants are its shadows.

**7.5 Where else the framework applies.** The counting framework of Section 2 uses nothing about cyclotomic fields. Any abelian extension with cyclic Galois group of order $n$ produces the same combinatorics via the Artin map; any multiplicative arithmetic function whose value at a prime depends only on a residue class fits the same product-additivity argument. The technique — reduce to a finite exponent box, symmetrise for free, split along CRT, decay-bound the atoms — should transfer to genus theory, to the distribution of Frobenius shapes in non-abelian settings (with conjugacy classes in place of orders), and to products of more than two primes.

---

## 8. Open problems and future work

**Conjecture 8.1 (Prime-power closed form).** For every prime $p$ and $k \ge 1$,
$$I_{\mathrm{pair}}(p^k) = \left(1 - p^{-2k}\right)\frac{p^2}{p^2-1}\,I_{\mathrm{pair}}(p).$$
Proved here for $p = 2$, $k \le 5$ and $p = 3$, $k \le 3$; numerically confirmed to $10^{-9}$ for $p = 2$, $k \le 7$ and $p = 3,5,7$, $k \le 3$. A proof should follow the valuation filtration $v(a) \in \{0,1,\dots,k\}$: the type of $a$ is $p^{\,k-v(a)}$, the sum $a+b$ has valuation $\min(v(a),v(b))$ off the diagonal, and the conditional law is a self-similar copy of the $p^{k-1}$ law; the geometric factor is the sum of the resulting series.

**Conjecture 8.2 (Supremum of the channel).** Combining 8.1 with additivity gives, for the "full" channel over all cyclic orders,
$$\sup_n I_{\mathrm{pair}}(n) \;=\; \sum_{p} \frac{p^2}{p^2-1} I_{\mathrm{pair}}(p),$$
a convergent sum by the $O(1/p)$ envelope (Theorem 5.15). Is the supremum attained in the limit along primorials, and what is its numeric value?

**Problem 8.3 (Exact above-cap classification).** Characterise $\{n : I_{\mathrm{pair}}(n) > 1\}$. Additivity reduces this to a knapsack over primary parts with the known atom weights; the two extreme cases (2-primary part $\ge 4$; enough odd atoms) are settled, but the exact boundary is open.

**Problem 8.4 (Non-abelian Frobenius shapes).** Replace the cyclic group by a general Galois group and the type by the Frobenius conjugacy class. Does an analogue of CRT additivity hold over the decomposition of the group, and does the cap fail in the same way?

**Problem 8.5 ($k$-almost-primes).** Extend from semiprimes to $N = p_1\cdots p_k$. The box becomes $(\mathbb{Z}/n)^k$, the readout the multiset of types, the conditioning variable the sum of exponents. Product additivity survives; the symmetrisation argument needs the full symmetric group in place of a single involution. How does $I$ grow with $k$?

---

## 9. Conclusion

The splitting type of a prime in a cyclic field is a complete, multi-state, totient-distributed invariant, determined exactly by a single residue and immune to modulus refinement. Its semiprime pair channel is a genuinely new exact object: additive over coprime factorisations, atomised by prime powers, with a closed form at prime atoms, geometric ladders at prime-power atoms, and infinitely many orders — including odd ones — strictly above the one-bit ceiling that governs binary forks. The classical split-count channel is recovered exactly as a small projection of it. The one-bit cap was never a law about semiprimes; it was a law about looking at them through a two-state window.
