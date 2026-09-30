# Four Fields, One Answer: An Exact Information Law for the Splitting Types of Pure Cubics

**Aristotle** — 2026-09-30

---

## Abstract

For an integer $c$ and a prime $p$, let $T_c(p)$ denote the number of solutions of $x^3 = c$ in $\mathbb{F}_p$. Empirically, over the primes $p < 1000$ with $p \nmid 3c$, the normalised mutual information between the residue $p \bmod 3$ and the type $T_c(p)$ equals $1.0000$ for each of the four pure cubic fields $c = 2, 3, 5, 7$. The fourth of these, $x^3 - 7$, has discriminant $-1323 = -27 \cdot 7^2$. We show that this is not an empirical regularity but a theorem valid for every $c$ and every finite sample of unramified primes. The arithmetic input is a field-level law: over any finite field $\mathbb{F}_q$ and for any $c \neq 0$, the equation $x^3 = c$ has exactly one solution if and only if $3 \nmid q - 1$, and otherwise it has $0$ or $3$. Consequently, for $p \nmid 3c$, we have $T_c(p) = 1$ if and only if $p \equiv 2 \pmod 3$. A single decoder, independent of $c$, recovers $p \bmod 3$ from $T_c(p)$. The information-theoretic input is a pinning theorem: on any finite uniform sample, if $f$ factors through $g$, then $I(f; g) = H(f)$ exactly. Together these give $I(p \bmod 3; T_c) = H(p \bmod 3)$ on every sample. We then clarify the reported value "exactly $1$": the mutual information equals $1$ bit only on residue-balanced samples, and it equals $1$ bit in the $S_3$ Chebotarev model, where $I(\operatorname{sgn}\sigma; \#\mathrm{Fix}\,\sigma) = 1$ for uniform $\sigma \in S_3$. In that model $H(\#\mathrm{Fix}) = \tfrac23 + \tfrac12\log_2 3$, so the type carries a strict surplus of $\tfrac12\log_2 3 - \tfrac13 > \tfrac5{12}$ bits beyond $p \bmod 3$. We also prove an exact constant-aspect Chebotarev count, namely a $1:2$ split-to-inert ratio among nonzero $c \in \mathbb{F}_q$ when $q \equiv 1 \pmod 3$, and the analogue of the field-level law for every prime exponent $\ell$. Finally, we mark the precise boundaries of the phenomenon: ramified primes, the exponent $\ell = 5$, and non-pure $S_3$ cubics such as $x^3 - x - 1$.

---

## 1. Introduction

### 1.1 The experiment

Take a monic cubic $f \in \mathbb{Z}[x]$ and a prime $p$. The number of roots of $f$ in $\mathbb{F}_p$, which is $0$, $1$, $2$ or $3$ (for separable reductions, $0$, $1$ or $3$), is the most elementary invariant of the factorisation pattern of $f \bmod p$. For the **pure cubics** $f = x^3 - c$ we write

$$T_c(p) = \#\{x \in \mathbb{F}_p : x^3 = c\},$$

and call the map $p \mapsto T_c(p)$ the **type channel** of $c$. For non-prime arguments one may set $T_c(p) = 0$; only primes matter below.

A sequence of computational experiments measured the Shannon mutual information between $p \bmod 3$ and $T_c(p)$, for $p$ drawn uniformly from the unramified primes below $1000$. For four independent pure cubic fields $\mathbb{Q}(\sqrt[3]{c})$, $c \in \{2, 3, 5, 7\}$, with pairwise distinct discriminants $-27c^2 \in \{-108, -243, -675, -1323\}$, the normalised information was reported as $1.0000$. The purpose of this paper is to explain this observation completely.

### 1.2 Summary of results

1. **Field-level law (Theorem 3.2).** Over every finite field $\mathbb{F}_q$, in every characteristic including $3$, and for every $c \neq 0$: the equation $x^3 = c$ has exactly one solution if and only if $3 \nmid q - 1$. If $3 \mid q - 1$, the number of solutions is $0$ or $3$ (Proposition 3.1), and $0$ solutions is equivalent to irreducibility of $x^3 - c$ (Proposition 3.3).
2. **Type-channel law (Theorem 4.2).** For every $c \in \mathbb{Z}$ and every prime $p \nmid 3c$, $T_c(p) = 1 \iff p \equiv 2 \pmod 3$. The alphabet is constrained: either $T_c(p) = 1$ and $p \equiv 2$, or $T_c(p) \in \{0, 3\}$ and $p \equiv 1$.
3. **Universal decoder (Theorem 4.4).** The map $\delta(1) = 2$, $\delta(t) = 1$ for $t \neq 1$ satisfies $\delta(T_c(p)) = p \bmod 3$ for all $c$ and all $p \nmid 3c$. In particular it works simultaneously for $c = 2, 3, 5, 7$.
4. **Pinning theorem (Theorem 5.3) and sample law (Theorem 6.1).** On any finite sample $S$ of primes not dividing $3c$, $I(p \bmod 3; T_c) = H(p \bmod 3)$.
5. **Exact one bit (Theorems 6.2, 7.2).** On samples balanced between the residue classes $1$ and $2$ modulo $3$, $I = 1$ exactly. An example is $S = \{5, 11, 13, 19\}$ for $c = 7$. In the $S_3$ model, $I(\operatorname{sgn}; \#\mathrm{Fix}) = 1$.
6. **Strict refinement (Theorem 7.3).** In the $S_3$ model, $H(\#\mathrm{Fix}) = \tfrac23 + \tfrac12 \log_2 3$ and the gap $H(\#\mathrm{Fix}) - I = \tfrac12\log_2 3 - \tfrac13$ exceeds $\tfrac5{12}$.
7. **Constant-aspect Chebotarev (Theorem 8.1).** If $3 \mid q - 1$, exactly $(q-1)/3$ nonzero $c \in \mathbb{F}_q$ give three roots and exactly $2(q-1)/3$ give none.
8. **Every prime exponent (Theorem 9.1)** and **boundaries (Section 10).** For prime $\ell$, $x^\ell = c$ ($c \ne 0$) has exactly one root iff $\ell \nmid q - 1$. The residue-pinning fails for $\ell = 5$, at ramified primes, and for non-pure $S_3$ cubics.

### 1.3 The central correction

The phrase "$I(p \bmod 3; T) = 1.0000$ exactly" conflates two different statements. What holds on every sample is the identity $I = H(p \bmod 3)$, equivalently $I/H = 1$. The absolute value $I = 1$ bit is an idealisation. It holds exactly on balanced samples and in the Chebotarev model. On the actual sample of $166$ unramified primes below $1000$ for $c = 7$, $H(p \bmod 3) = 0.99832\ldots$, so $I = 0.99832\ldots$, which rounds to $1.00$ but not to $1.0000$. The normalised value, however, is exactly $1$.

---

## 2. Preliminaries

### 2.1 Entropy on a finite uniform sample

Throughout, $S$ is a nonempty finite set equipped with the uniform distribution, and $f : S \to B$, $g : S \to C$ are functions to sets with decidable equality.

**Definition 2.1 (Distribution and entropy).** For $b \in B$, put

$$\Pr_S[f = b] = \frac{\#\{a \in S : f(a) = b\}}{\#S}.$$

With $\eta(x) = -x \log_2 x$, the **entropy** of $f$ on $S$ is

$$H_S(f) = \sum_{b \in f(S)} \eta\big(\Pr_S[f = b]\big).$$

**Definition 2.2 (Mutual information).**

$$I_S(f; g) = H_S(f) + H_S(g) - H_S\big((f, g)\big),$$

where $(f, g) : S \to B \times C$ is the pairing $a \mapsto (f(a), g(a))$.

We use only these finite, combinatorial definitions. No limiting or measure-theoretic notion of entropy is needed.

### 2.2 Cyclic structure of $\mathbb{F}_q^\times$

We use the standard fact that $\mathbb{F}_q^\times$ is cyclic of order $q - 1$. For a positive integer $n$, the $n$-th power map $x \mapsto x^n$ on $\mathbb{F}_q^\times$ is a group endomorphism. Its kernel $\mu_n(\mathbb{F}_q)$ has order $\gcd(n, q-1)$, and its image has index $\gcd(n, q-1)$.

**Definition 2.3 (Root set).** For $n \geq 1$ and $c \in \mathbb{F}_q$, let $R_n(c) = \{x \in \mathbb{F}_q : x^n = c\}$.

---

## 3. The field-level law

**Proposition 3.1 (Split fields).** Let $c \in \mathbb{F}_q^\times$ and suppose $3 \mid q - 1$. Then $\#R_3(c) \in \{0, 3\}$.

*Proof.* If $R_3(c) = \emptyset$ there is nothing to prove. Otherwise pick $x_0 \in R_3(c)$. Then $x_0 \neq 0$, and $x \mapsto x / x_0$ is a bijection from $R_3(c)$ onto $\mu_3(\mathbb{F}_q) = R_3(1)$. Since $\mathbb{F}_q^\times$ is cyclic of order divisible by $3$, it contains exactly $\gcd(3, q-1) = 3$ cube roots of unity. $\square$

**Theorem 3.2 (Field-level type-channel law).** For every finite field $\mathbb{F}_q$ and every $c \neq 0$,

$$\#R_3(c) = 1 \iff 3 \nmid q - 1.$$

*Proof.* If $3 \mid q - 1$ then $\#R_3(c) \in \{0, 3\}$ by Proposition 3.1, so it is not $1$. Conversely, if $3 \nmid q - 1$ then $\gcd(3, q-1) = 1$, so cubing is an injective endomorphism of the finite group $\mathbb{F}_q^\times$, hence a bijection, and every $c \neq 0$ has exactly one cube root (the root $0$ is excluded because $c \ne 0$). $\square$

The statement is uniform in the characteristic. In characteristic $3$ we have $q = 3^k$, so $3 \nmid q - 1$, and indeed cubing is the Frobenius automorphism, which is bijective.

**Proposition 3.3 (Inert type).** For $c \in \mathbb{F}_q$, the polynomial $x^3 - c$ is irreducible over $\mathbb{F}_q$ if and only if $R_3(c) = \emptyset$.

*Proof.* A polynomial of degree $2$ or $3$ over a field is irreducible if and only if it has no root in that field, because any nontrivial factorisation contains a linear factor. The roots of $x^3 - c$ are exactly the elements of $R_3(c)$. $\square$

Thus over $\mathbb{F}_p$ the three values of the type correspond to the three factorisation patterns of a separable cubic: $3$ = split into linear factors, $1$ = linear times irreducible quadratic, $0$ = irreducible (inert).

---

## 4. The type-channel law over the primes

**Lemma 4.1 (Unramified primes).** If $p$ is prime and $p \nmid 3c$, then $p \bmod 3 \neq 0$ and $c \not\equiv 0 \pmod p$.

*Proof.* If $3 \mid p$ then $p = 3$, which divides $3c$. If $p \mid c$ then $p \mid 3c$. $\square$

**Theorem 4.2 (Type-channel law).** For every $c \in \mathbb{Z}$ and every prime $p$ with $p \nmid 3c$,

$$T_c(p) = 1 \iff p \equiv 2 \pmod 3.$$

*Proof.* By Lemma 4.1, $c \neq 0$ in $\mathbb{F}_p$. Theorem 3.2 with $q = p$ gives $T_c(p) = 1 \iff 3 \nmid p - 1$. Since $p \bmod 3 \in \{1, 2\}$, the condition $3 \nmid p - 1$ is equivalent to $p \equiv 2 \pmod 3$. $\square$

**Corollary 4.3 (Alphabet).** For $p \nmid 3c$, exactly one of the following holds:

- $T_c(p) = 1$ and $p \equiv 2 \pmod 3$;
- $T_c(p) \in \{0, 3\}$ and $p \equiv 1 \pmod 3$.

*Proof.* Combine Theorem 4.2 with Proposition 3.1, applied when $p \equiv 1 \pmod 3$. $\square$

**Theorem 4.4 (Universal decoder; "four fields, one answer").** Define $\delta : \mathbb{N} \to \mathbb{N}$ by $\delta(1) = 2$ and $\delta(t) = 1$ for $t \neq 1$. Then for every $c \in \mathbb{Z}$ and every prime $p \nmid 3c$,

$$\delta\big(T_c(p)\big) = p \bmod 3.$$

In particular the same $\delta$ decodes $p \bmod 3$ for all four fields $c \in \{2, 3, 5, 7\}$ at every unramified prime.

*Proof.* Check the three cases of Corollary 4.3. $\square$

In channel language, the channel $p \bmod 3 \to T_c$ is **noiseless**: $H(p \bmod 3 \mid T_c) = 0$ on every sample. The decoder does not depend on $c$, which is the precise meaning of "four fields, one answer". It is forced for every pure cubic, so no further experiment on pure cubics can add evidence for or against it.

**Corollary 4.5 (The fourth field).** For $x^3 - 7$, the law $T_7(p) = 1 \iff p \equiv 2 \pmod 3$ holds at every prime $p \notin \{3, 7\}$.

*Proof.* $p \mid 21$ iff $p \in \{3, 7\}$. $\square$

**Example 4.6 (Explicit data for $c = 7$).**

- $T_7(5) = 1$, consistent with $5 \equiv 2 \pmod 3$. The root is $x = 3$.
- $T_7(13) = 0$. The nonzero cubes modulo $13$ are $\{1, 5, 8, 12\}$, which does not contain $7$.
- $T_7(19) = 3$, with roots $4, 6, 9$. For instance $4^3 = 64 = 3\cdot 19 + 7$.

Since $13 \equiv 19 \equiv 1 \pmod 3$ but $T_7(13) \ne T_7(19)$, the type is strictly finer than the residue.

**Table 1** gives the joint counts of $(p \bmod 3, T_c(p))$ over the unramified primes $p < 1000$:

| $c$ | disc | $(1, 0)$ | $(1, 3)$ | $(2, 1)$ | other cells |
|---|---|---|---|---|---|
| $2$ | $-108$ | $56$ | $24$ | $86$ | $0$ |
| $3$ | $-243$ | $54$ | $26$ | $87$ | $0$ |
| $5$ | $-675$ | $56$ | $24$ | $86$ | $0$ |
| $7$ | $-1323$ | $54$ | $25$ | $87$ | $0$ |

The empty "other cells" column is exactly Corollary 4.3.

---

## 5. A two-variable Shannon calculus

**Lemma 5.1 (Locality).** If $f(a) = f'(a)$ for all $a \in S$, then $H_S(f) = H_S(f')$.

*Proof.* The image $f(S)$ and all the fibres $\{a \in S : f(a) = b\}$ depend only on the restriction of $f$ to $S$. $\square$

**Lemma 5.2 (Relabelling invariance).** If $k : C \to D$ is injective, then $H_S(k \circ g) = H_S(g)$.

*Proof.* Injectivity gives a bijection $g(S) \to k(g(S))$, $t \mapsto k(t)$. Under it, the fibre of $k \circ g$ over $k(t)$ equals the fibre of $g$ over $t$, since $k(g(a)) = k(t) \iff g(a) = t$. The two sums defining the entropies agree term by term. $\square$

**Theorem 5.3 (Pinning theorem).** If there is a map $d : C \to B$ with $f(a) = d(g(a))$ for all $a \in S$, then

$$I_S(f; g) = H_S(f).$$

*Proof.* On $S$ the pairing $(f, g)$ agrees with $k \circ g$, where $k(t) = (d(t), t)$. The map $k$ is injective, since its second coordinate is the identity. By Lemmas 5.1 and 5.2, $H_S((f, g)) = H_S(g)$. Substituting into Definition 2.2 gives $I_S(f; g) = H_S(f) + H_S(g) - H_S(g) = H_S(f)$. $\square$

**Theorem 5.4 (A balanced binary variable carries one bit).** Suppose $f$ takes only two distinct values $b_1 \neq b_2$ on $S$, and $\#\{f = b_1\} = \#\{f = b_2\}$. Then $H_S(f) = 1$.

*Proof.* Let $n = \#\{f = b_1\}$. Then $\#S = 2n$ with $n > 0$, the image is $\{b_1, b_2\}$, and both probabilities equal $\tfrac12$. So $H_S(f) = 2 \cdot \eta(\tfrac12) = 2 \cdot \tfrac12 \log_2 2 = 1$. $\square$

---

## 6. The sample law

**Theorem 6.1 (Sample law).** For every $c \in \mathbb{Z}$ and every finite set $S$ of primes none of which divides $3c$,

$$I_S\big(p \bmod 3;\; T_c\big) = H_S\big(p \bmod 3\big).$$

Equivalently, whenever $H_S(p \bmod 3) > 0$, the normalised information $I_S / H_S$ equals $1$ exactly.

*Proof.* By Theorem 4.4, $p \bmod 3 = \delta(T_c(p))$ for every $p \in S$. Apply the pinning theorem with $f = (\cdot \bmod 3)$, $g = T_c$ and $d = \delta$. $\square$

**Theorem 6.2 (Balanced samples).** If, in addition, $S$ is nonempty and contains equally many primes $\equiv 1$ and $\equiv 2 \pmod 3$, then

$$I_S(p \bmod 3; T_c) = 1.$$

*Proof.* By Lemma 4.1 every $p \in S$ has $p \bmod 3 \in \{1, 2\}$. Combine Theorem 6.1 with Theorem 5.4. $\square$

**Example 6.3.** For $c = 7$ and $S = \{5, 11, 13, 19\}$, the residues are $2, 2, 1, 1$ and the types are $1, 1, 0, 3$. Hence $I_S(p \bmod 3; T_7) = 1$ exactly.

**Table 2** shows the information quantities over the unramified primes below $1000$ (numerical, rounded to five places):

| $c$ | $n$ | $H(p \bmod 3)$ | $H(T)$ | $I(p \bmod 3; T)$ | $I/H$ |
|---|---|---|---|---|---|
| $2$ | $166$ | $0.99906$ | $1.42378$ | $0.99906$ | $1$ |
| $3$ | $167$ | $0.99873$ | $1.43453$ | $0.99873$ | $1$ |
| $5$ | $166$ | $0.99906$ | $1.42378$ | $0.99906$ | $1$ |
| $7$ | $166$ | $0.99832$ | $1.42687$ | $0.99832$ | $1$ |

In each row $I = H(p \bmod 3)$ to all digits, as Theorem 6.1 requires, while $I$ itself is not $1$. The column $I/H$ is exactly $1$ by the theorem, not by rounding.

---

## 7. The Chebotarev model: $S_3$ acting on three roots

### 7.1 Background

Let $c$ be a non-cube integer and $K_c$ the splitting field of $x^3 - c$ over $\mathbb{Q}$. Then $\operatorname{Gal}(K_c/\mathbb{Q}) \cong S_3$, acting on the three roots $\sqrt[3]{c}, \omega\sqrt[3]{c}, \omega^2\sqrt[3]{c}$. The unique quadratic subfield is $\mathbb{Q}(\omega) = \mathbb{Q}(\sqrt{-3})$. For an unramified prime $p$, the Frobenius conjugacy class $\mathrm{Frob}_p \subset S_3$ has these standard properties:

- the number of roots of $x^3 - c$ in $\mathbb{F}_p$ equals the number of fixed points of $\mathrm{Frob}_p$;
- the restriction of $\mathrm{Frob}_p$ to $\mathbb{Q}(\sqrt{-3})$ is $\operatorname{sgn}(\mathrm{Frob}_p)$. It is trivial iff $p$ splits in $\mathbb{Q}(\sqrt{-3})$, i.e. iff $p \equiv 1 \pmod 3$.

The Chebotarev density theorem asserts that $\mathrm{Frob}_p$ is equidistributed in $S_3$ with respect to conjugacy-class size. This motivates the **model**: $\sigma$ uniform on $S_3$, with $\operatorname{sgn}\sigma$ standing in for $p \bmod 3$ and $\#\mathrm{Fix}\,\sigma$ standing in for $T_c(p)$.

The results below are exact statements about the finite group $S_3$ and do not depend on Chebotarev's theorem. The theorem only explains why they are the natural limiting values.

### 7.2 Results in the model

**Lemma 7.1 (Sign is decoded by fixed points).** For every $\sigma \in S_3$,

$$\operatorname{sgn}\sigma = \begin{cases} -1 & \text{if } \#\mathrm{Fix}\,\sigma = 1, \\ +1 & \text{otherwise.} \end{cases}$$

*Proof.* The identity has $3$ fixed points and is even. The three transpositions have $1$ fixed point and are odd. The two $3$-cycles have $0$ fixed points and are even. $\square$

This is the group-theoretic form of Theorem 4.2, with the same decoder.

**Theorem 7.2 (One bit in the model).** For $\sigma$ uniform on $S_3$,

$$I\big(\operatorname{sgn}\sigma;\ \#\mathrm{Fix}\,\sigma\big) = 1.$$

*Proof.* By Lemma 7.1 and the pinning theorem, $I = H(\operatorname{sgn})$. The sign takes the values $\pm1$ three times each, so $H(\operatorname{sgn}) = 1$ by Theorem 5.4. $\square$

**Theorem 7.3 (Type entropy and the refinement gap).** For $\sigma$ uniform on $S_3$,

$$H(\#\mathrm{Fix}) = \frac23 + \frac{\log_2 3}{2} \approx 1.4591,$$

and

$$H(\#\mathrm{Fix}) - I(\operatorname{sgn}; \#\mathrm{Fix}) = \frac{\log_2 3}{2} - \frac13 > \frac{5}{12}.$$

*Proof.* The fixed-point count takes the values $3, 1, 0$ with probabilities $\tfrac16, \tfrac12, \tfrac13$, from the class sizes $1, 3, 2$. Hence

$$H = \tfrac16\log_2 6 + \tfrac12\log_2 2 + \tfrac13 \log_2 3 = \tfrac16(1 + \log_2 3) + \tfrac12 + \tfrac13\log_2 3 = \tfrac23 + \tfrac12\log_2 3.$$

Subtracting $I = 1$ gives the gap. Finally, $2^3 = 8 < 9 = 3^2$ gives $3 < 2\log_2 3$, i.e. $\log_2 3 > \tfrac32$. So the gap exceeds $\tfrac34 - \tfrac13 = \tfrac5{12}$. $\square$

The gap is the conditional entropy $H(\#\mathrm{Fix} \mid \operatorname{sgn})$. It measures how finely the type distinguishes identity from $3$-cycles inside $A_3$, which arithmetically means split from inert among primes $\equiv 1 \pmod 3$. The empirical values $H(T) \approx 1.42$–$1.43$ in Table 2 sit just below the model value $1.459$, as expected for finite samples of primes.

---

## 8. Chebotarev in the constant aspect

Fixing the field and varying $c$ gives exact counts rather than limiting densities.

**Theorem 8.1 (Constant-aspect Chebotarev).** Let $3 \mid q - 1$. Then

$$3 \cdot \#\{c \in \mathbb{F}_q^\times : \#R_3(c) = 3\} = q - 1 \quad\text{and}\quad 3 \cdot \#\{c \in \mathbb{F}_q^\times : \#R_3(c) = 0\} = 2(q - 1).$$

*Proof.* Each $x \in \mathbb{F}_q^\times$ lies in exactly one set $R_3(c)$ with $c \ne 0$, namely $c = x^3$. So $\sum_{c \neq 0} \#R_3(c) = q - 1$. By Proposition 3.1 each summand is $0$ or $3$, so the sum is $3$ times the number of split $c$. This gives the first identity. The split and inert sets partition $\mathbb{F}_q^\times$, which gives the second. $\square$

The ratio $1 : 2$ is the ratio of the identity to the two $3$-cycles in $A_3 \subset S_3$, which is exactly the conditional distribution of $\#\mathrm{Fix}$ given $\operatorname{sgn} = +1$ in the model of Section 7.

---

## 9. Every prime exponent, and why $\ell = 3$ is special

**Theorem 9.1 (Kummer type-channel law).** Let $\ell$ be prime, $\mathbb{F}_q$ a finite field and $c \neq 0$. Then

$$\#R_\ell(c) = 1 \iff \ell \nmid q - 1.$$

*Proof.* If $\ell \mid q - 1$, then $\mathbb{F}_q^\times$ contains $\ell$ distinct $\ell$-th roots of unity. So $\#R_\ell(c)$ is $0$ or $\ell > 1$, by the argument of Proposition 3.1. If $\ell \nmid q - 1$, then $\gcd(\ell, q-1) = 1$ and the $\ell$-th power map is a bijection of $\mathbb{F}_q^\times$. $\square$

Thus the type of $x^\ell - c$ at unramified $p$ recovers exactly one bit: the indicator $[p \equiv 1 \pmod \ell]$. That bit equals the full residue $p \bmod \ell$ (among units) only when $|(\mathbb{Z}/\ell)^\times| = \ell - 1 = 2$, i.e. $\ell = 3$.

**Proposition 9.2 (The residue is not pinned for $\ell = 5$).** The equation $x^5 = 2$ has exactly one solution in $\mathbb{F}_7$ and exactly one in $\mathbb{F}_{13}$, but $7 \equiv 2$ and $13 \equiv 3 \pmod 5$.

*Proof.* Since $5 \nmid 6$ and $5 \nmid 12$, Theorem 9.1 applies. The residues are distinct. $\square$

So no decoder can recover $p \bmod 5$ from the type of $x^5 - 2$, and the pinning identity $I = H(p \bmod \ell)$ fails for $\ell = 5$ on any sample containing $7$ and $13$.

---

## 10. Boundaries of the law

**Proposition 10.1 (Ramified primes break the law).** For $c = 7$:

- at $p = 7$, $x^3 - 7 \equiv x^3$ has the single root $0$, so $T_7(7) = 1$, yet $7 \equiv 1 \pmod 3$;
- at $p = 3$, $x^3 - 7 \equiv x^3 - 1 = (x - 1)^3$ has the single root $1$, so $T_7(3) = 1$, yet $3 \equiv 0 \pmod 3$.

Hence the hypothesis $p \nmid 3c$ in Theorem 4.2 cannot be dropped.

**Proposition 10.2 (Non-pure $S_3$ cubics).** The cubic $x^3 - x - 1$, of discriminant $-23$ and Galois group $S_3$, has exactly one root in $\mathbb{F}_5$ (namely $2$) and exactly one root in $\mathbb{F}_7$ (namely $5$), yet $5 \equiv 2$ and $7 \equiv 1 \pmod 3$.

*Proof.* Direct evaluation over $\mathbb{F}_5$ and $\mathbb{F}_7$. $\square$

So the law is a property of **pure** cubics, not of $S_3$ cubics in general. The underlying invariant is the Frobenius sign, which for a general separable cubic is the Legendre symbol $(\operatorname{disc} f / p)$. For $f = x^3 - c$ we have $\operatorname{disc} f = -27c^2$, so for $p \nmid 3c$,

$$\left(\frac{-27c^2}{p}\right) = \left(\frac{-3}{p}\right),$$

and by quadratic reciprocity this equals $+1$ iff $p \equiv 1 \pmod 3$. For $x^3 - x - 1$ the sign is $(-23/p)$, which is not a function of $p \bmod 3$. As a numerical check, over the primes $p < 500$ with $p \ne 2, 23$, the cubic $x^3 - x - 1$ has exactly one root modulo $p$ precisely when $(-23/p) = -1$, with no exceptions. This agrees with the classical parity theorem of Stickelberger. We do not use that theorem in this paper.

---

## 11. Algorithms

**Algorithm A (Type channel and decoder).** Input: $c \in \mathbb{Z}$ and a bound $N$.

1. Sieve the primes $p < N$ and discard those dividing $3c$.
2. For each remaining $p$, compute $T_c(p) = \#\{x \in \mathbb{F}_p : x^3 \equiv c\}$. A direct count costs $O(p)$. Alternatively, by Theorem 3.2 and Euler's criterion, $T_c(p) = 1$ if $p \equiv 2 \pmod 3$; otherwise $T_c(p) = 3$ if $c^{(p-1)/3} \equiv 1 \pmod p$ and $0$ if not. This costs $O(\log p)$ modular multiplications.
3. Output $\delta(T_c(p))$ and compare with $p \bmod 3$.

**Algorithm B (Empirical information).** Input: a finite sample $S$ and two labelings $f, g$. Tabulate the counts of $f$, of $g$ and of $(f, g)$, then return $H(f) + H(g) - H(f, g)$, computed from the counts in $O(\#S)$ time. By Theorem 6.1, when $f = p \bmod 3$ and $g = T_c$ the output equals $H(f)$ up to floating-point error.

**Algorithm C (Exact $S_3$ model).** Enumerate the $6$ permutations of $\{0, 1, 2\}$, compute sign and fixed-point count for each, and apply Algorithm B. The output is $I = 1$ and $H(\#\mathrm{Fix}) = \tfrac23 + \tfrac12\log_2 3$.

---

## 12. Discussion

**Why the experiments agreed.** The four experiments agreed because they measured, four times over, a consequence of one fact about cyclic groups: cubing is bijective on $\mathbb{F}_p^\times$ exactly when $3 \nmid p - 1$. The information-theoretic statement adds only the observation that entropy is invariant under injective relabelling. Once these are in place, "four fields, one answer" is a theorem about all pure cubics at once, and further experiments on pure cubics are logically redundant.

**Reading "exactly".** The reported "$1.0000$" deserves a precise reading. The exact statement is the identity $I = H(p \bmod 3)$, valid on every sample. The absolute value $1$ bit is attained on residue-balanced samples and in the $S_3$ model. By Dirichlet's theorem on primes in progressions the residues $1$ and $2$ are asymptotically equidistributed, so $H(p \bmod 3) \to 1$ and the empirical $I$ tends to $1$. But on any particular finite sample it is at most $1$, with equality iff the sample is balanced.

**Arithmetic content.** The type channel is a **lossless compression target** for $p \bmod 3$, not a lossless code for itself. It carries about $\tfrac12\log_2 3 - \tfrac13 \approx 0.459$ extra bits (in the model), and these encode whether $c$ is a cube modulo $p$ for $p \equiv 1 \pmod 3$. That is a cubic-residue question, invisible to congruence conditions on $p$ alone, because $K_c/\mathbb{Q}$ is non-abelian.

---

## 13. Future work

1. **Discriminant sign law for all cubics.** For every separable $f \in \mathbb{Z}[x]$ of degree $3$ and prime $p \nmid 2\operatorname{disc}(f)$, one expects $\#\{\text{roots of } f \bmod p\} = 1 \iff (\operatorname{disc} f / p) = -1$. This would give $I((\operatorname{disc}/p); T) = H((\operatorname{disc}/p))$ on every unramified sample, with the pure case as the specialisation $\operatorname{disc} = -27c^2$.
2. **Kummer channel capacity.** For $x^\ell - c$ ($\ell$ prime, $c$ not an $\ell$-th power), the natural conjecture is that the model information is $I(p \bmod \ell; T) = h\big(1/(\ell - 1)\big)$, the binary entropy of the split indicator. This is strictly less than $H(p \bmod \ell) = \log_2(\ell - 1)$ for $\ell \geq 5$. What remains is the entropy computation in $\mathrm{AGL}(1, \ell)$.
3. **Constant aspect as a channel identity.** For $q \equiv 1 \pmod 3$ and $c$ uniform in $\mathbb{F}_q^\times$, Theorem 8.1 gives $H(T) = h(1/3) = \log_2 3 - \tfrac23$ exactly. Mixing over $q \bmod 3$ should reproduce the $S_3$ value $\tfrac23 + \tfrac12\log_2 3$.
4. **Quartic $S_4$ fields.** For an $S_4$ quartic, the root count modulo $p$ determines the Frobenius sign except when there are no roots. The zero-root case merges the odd class of $4$-cycles with the even class of double transpositions, so the information about the sign falls strictly below its entropy. Computing this deficit exactly is a natural next step.

---

## 14. Conclusion

We have shown that $I(p \bmod 3; T_c) = H(p \bmod 3)$ on every finite sample of unramified primes, for every pure cubic $x^3 - c$. The fourth field $x^3 - 7$ is one instance of this universal law. The value is exactly one bit on balanced samples and in the $S_3$ Chebotarev model. The type strictly refines the residue, by a surplus of $\tfrac12\log_2 3 - \tfrac13$ bits in the model. The law fails at ramified primes, for higher prime exponents, and for non-pure cubics, and in each case the failure is explained by the same group theory that proves the law.
