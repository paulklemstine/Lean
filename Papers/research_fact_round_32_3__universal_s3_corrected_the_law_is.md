# The Law Is Universal, the Conductor Is Not: One-Bit Sign Channels in $S_3$ Cubic Fields

**Aristotle**

*2026-09-26*

---

## Abstract

Let $K$ be the splitting field of an irreducible rational cubic with Galois group $S_3$. For each unramified prime $p$, the *splitting type* of the cubic modulo $p$ (three roots, one root, or none) is the cycle type of the Frobenius permutation. We study how much information the splitting type carries about the sign character of Frobenius, and where that character can be read off from $p$ itself.

Our first result is group-theoretic and fully general. For every finite group $G$ with the uniform measure, every surjective character $\chi : G \to \{\pm 1\}$, and every type function $T$ on $G$ through which $\chi$ factors, the mutual information is exactly one bit: $I(\chi; T) = 1$. No type function can carry more than one bit about $\chi$. The same holds for the product character on $G \times G$ (the "semiprime pair channel"), and a function of one coordinate of a product carries zero information about a function of the other ("coprime moduli are flat"). Since the shape of the channel depends only on the group, it is the same for every $S_3$-field.

Our second group of results is arithmetic. We give an elementary proof of Stickelberger's parity law for depressed cubics $x^3 + ax + b$ over $\mathbb{F}_p$ ($p$ odd, $\Delta = -4a^3 - 27b^2 \neq 0$): the cubic has exactly one root in $\mathbb{F}_p$ if and only if $\Delta$ is a non-square. The reducible half rests on the identity $\Delta = (-3r^2 - 4a)(3r^2 + a)^2$ for a root $r$, and holds over every field of characteristic $\ne 2$. The irreducible half rests on a Frobenius 3-cycle on the roots in $\mathbb{F}_p[x]/(f)$. We then compare $x^3 - 2$ ($\Delta = -108 = -3\cdot 6^2$) with $x^3 + x + 1$ ($\Delta = -31$). For $x^3 - 2$ and every prime $p > 3$, there is exactly one root iff $p \equiv 2 \pmod 3$, and as a by-product the cubic yields the quadratic character of $-3$. For $x^3 + x + 1$ and every prime $p \notin \{2, 31\}$, there is exactly one root iff $\left(\frac{p}{31}\right) = -1$. The primes $5 \equiv 11 \pmod 3$ show that the sign bit of $x^3 + x + 1$ is not a function of $p \bmod 3$.

**Corrected verdict.** The one-bit law is universal in the shape of the channel, which is dictated by the group. The conductor at which the bit can be read is dictated by the discriminant: $3$ for $x^3-2$, $31$ for $x^3+x+1$.

---

## 1. Introduction

### 1.1 The experiment and its claim

The experiment behind this paper reduced two $S_3$ cubics modulo primes and recorded the splitting type $T(p)$ at each prime. The first was $x^3 + x + 1$, of discriminant $-31$, studied earlier; the second, new one was $x^3 - 2$, of discriminant $-108$. Three findings were reported for the new field:

1. the residue $p \bmod 3$ and the splitting type share exactly one bit of information, $I(p \bmod 3; T) = 1.0000$;
2. the analogous "semiprime pair" channel, in which a pair of primes $(p,q)$ is compared through $(T(p), T(q))$ and $pq \bmod 3$, carries exactly one bit;
3. moduli unrelated to the field carry no information ("coprime moduli are flat").

These findings match those for $x^3 + x + 1$, which led to the assertion that *the type-channel law depends only on group structure, not on which polynomial realizes the group*.

This paper states that assertion precisely and proves it, and in doing so finds its limit. One reading of the law is a statement about the pair (sign character, cycle type) on $S_3$. That reading is universal and holds for every finite group with a sign-type character. A second reading pins the sign character to "conductor 3". That reading is true for $x^3 - 2$ and false for $x^3 + x + 1$, whose sign character lives at conductor $31$.

### 1.2 Summary of results

* **Universal Sign-Channel Theorem (Theorem 3.1).** $I(\chi; T) = 1$ for every finite group $G$, every surjective character $\chi: G \to \{\pm1\}$, and every $T$ through which $\chi$ factors. Instances include $S_3$ with its cycle type, every $S_n$ with $n \ge 2$, and the pair channel on $G\times G$. The bound $I(\chi;T) \le 1$ holds for arbitrary $T$ (Proposition 3.5), and a product law gives vanishing information between independent coordinates (Theorem 3.6).
* **Sign Law over $\mathbb{F}_p$ (Theorem 4.7).** For odd $p$ and $\Delta \ne 0$, $x^3+ax+b$ has exactly one root in $\mathbb{F}_p$ iff $\Delta$ is a non-square in $\mathbb{F}_p$.
* **Pure Cubic Theorem (Theorem 5.3).** For primes $p>3$, $x^3 - 2$ has exactly one root mod $p$ iff $p \equiv 2 \pmod 3$. As a corollary, $-3$ is a square mod $p$ iff $p \equiv 1 \pmod 3$.
* **Trinomial Theorem (Theorem 6.3).** For primes $p \notin\{2,31\}$, $x^3+x+1$ has exactly one root mod $p$ iff $\left(\frac{p}{31}\right) = -1$. Hence the sign bit depends only on $p \bmod 31$.
* **Conductor Separation (Theorem 6.6).** For $x^3+x+1$, the primes $5$ and $11$ agree mod $3$ but have opposite Frobenius signs. On the sample $\{5,11\}$, the mod-$3$ channel carries $0$ bits and the mod-$31$ channel carries $1$ bit.

### 1.3 Conventions

$\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$. "Square" means a square in the field under consideration, and $0$ counts as a square. $\left(\frac{a}{p}\right)$ is the Legendre symbol. All logarithms are base $2$, so entropies are measured in bits. For a depressed cubic we write
$$f_{a,b}(x) = x^3 + ax + b, \qquad \Delta(a,b) = -4a^3 - 27b^2.$$

---

## 2. Entropy on finite sets

All information-theoretic quantities in this paper are taken with respect to the **uniform measure** on a finite set. For $S_3$-fields this is the natural choice: by the Chebotarev density theorem, Frobenius elements of unramified primes are equidistributed in the Galois group with respect to the normalised counting (Haar) measure. The theorems below are exact statements about the uniform measure on a group, or on an explicit finite set of primes. They do not depend on Chebotarev; Chebotarev is only what connects them to prime statistics.

**Definition 2.1 (Entropy, conditional entropy, mutual information).** Let $s$ be a finite nonempty set, $N = |s|$, and let $g, k$ be functions on $s$. For $a \in s$ write $n_g(a) = |\{x \in s : g(x) = g(a)\}|$ for the size of the fibre of $g$ through $a$. Define

$$H_s(g) = \log_2 N - \frac{1}{N} \sum_{a \in s} \log_2 n_g(a) = -\sum_{v \in g(s)} \frac{|g^{-1}(v)|}{N} \log_2 \frac{|g^{-1}(v)|}{N},$$

$$H_s(g \mid k) = \sum_{c \in k(s)} \frac{|s_c|}{N}\, H_{s_c}(g), \qquad s_c = \{x \in s : k(x) = c\},$$

$$I_s(g; k) = H_s(g) - H_s(g \mid k).$$

For $s = \varnothing$ all three quantities are set to $0$. These are Shannon's entropy, conditional entropy and mutual information of the random variables $g$ and $k$ under the uniform distribution on $s$. All are non-negative.

**Lemma 2.2 (Equal fibres).** If every fibre of $g$ on $s$ has the same cardinality $c$, then $H_s(g) = \log_2 |s| - \log_2 c$.

*Proof.* The sum $\sum_{a}\log_2 n_g(a)$ equals $|s| \log_2 c$. $\square$

In particular, a function that is constant on $s$ has $c = |s|$, so its entropy is $0$.

**Lemma 2.3 (Factorisation kills conditional entropy).** Suppose $g$ is determined by $k$ on $s$, that is, $k(x) = k(y) \Rightarrow g(x) = g(y)$ for $x, y \in s$. Then $H_s(g \mid k) = 0$, and hence $I_s(g;k) = H_s(g)$.

*Proof.* On each fibre $s_c$ of $k$ the function $g$ is constant, so $H_{s_c}(g) = 0$ by Lemma 2.2. $\square$

**Proposition 2.4 (Haar push-forward along a homomorphism).** Let $\chi : G \to H$ be a homomorphism of groups with $G$ finite, and give $G$ the uniform measure. Then
$$H_G(\chi) = \log_2 |\chi(G)|.$$

*Proof.* The fibre of $\chi$ through $a$ is the coset $a\ker\chi$: the map $x \mapsto a^{-1}x$ is a bijection from $\{x : \chi(x) = \chi(a)\}$ onto $\ker \chi$. So all fibres have size $|\ker\chi|$. By Lemma 2.2 and Lagrange's theorem $|G| = |\ker \chi|\cdot|\chi(G)|$, we get $H_G(\chi) = \log_2|G| - \log_2|\ker\chi| = \log_2|\chi(G)|$. $\square$

**Corollary 2.5.** If $\chi: G \to \{\pm 1\}$ is a surjective homomorphism, then $H_G(\chi) = 1$.

---

## 3. The universal sign channel

**Theorem 3.1 (Universal Sign-Channel Theorem).** Let $G$ be a finite group with the uniform measure, let $\chi : G \to \{\pm1\}$ be a surjective homomorphism, and let $T : G \to \tau$ be any function such that
$$T(g) = T(h) \ \Longrightarrow\ \chi(g) = \chi(h) \qquad (g,h \in G).$$
Then $I_G(\chi; T) = 1$.

*Proof.* By Lemma 2.3, $I_G(\chi;T) = H_G(\chi)$, and by Corollary 2.5 this equals $1$. $\square$

Only three ingredients enter the proof: the group, the index-two subgroup $\ker\chi$, and the fact that $T$ refines the coset decomposition $G = \ker\chi \sqcup g_0\ker\chi$. The polynomial that realises the group plays no role.

**Corollary 3.2 ($S_3$ and all symmetric groups).** For every $n \ge 2$, with $G = S_n$, $\chi = \operatorname{sgn}$ and $T = $ cycle type, we have $I(\operatorname{sgn}; \text{cycle type}) = 1$. In particular this holds for $S_3$. Therefore, for every $S_3$-field, whether it is the splitting field of $x^3 - 2$, of $x^3 + x + 1$, or of any other cubic with full Galois group, the Chebotarev-distributed splitting type carries exactly one bit about the sign of Frobenius.

*Proof.* The sign is surjective for $n \ge 2$. It is a function of cycle type, since a permutation with cycle lengths $\ell_1,\dots,\ell_k$ has sign $\prod(-1)^{\ell_i - 1}$. $\square$

For a cubic, the dictionary between splitting type modulo an unramified prime $p$ and Frobenius is

| roots mod $p$ | splitting type | cycle type of $\mathrm{Frob}_p$ | sign | Haar measure |
|---|---|---|---|---|
| 3 | $1+1+1$ | identity | $+1$ | $1/6$ |
| 1 | $1+2$ | transposition | $-1$ | $1/2$ |
| 0 | $3$ | 3-cycle | $+1$ | $1/3$ |

So the sign bit is the event "exactly one root mod $p$".

**Definition 3.3 (Pair character).** For a character $\chi : G \to \{\pm1\}$, the pair character on $G\times G$ is $(\chi\cdot\chi)(g,h) = \chi(g)\chi(h)$. For a semiprime $pq$ it models the product of the signs of the two Frobenius elements.

**Theorem 3.4 (Semiprime pair channel).** Under the hypotheses of Theorem 3.1, the pair of types $(T(g), T(h))$ carries exactly one bit about $\chi(g)\chi(h)$ under the uniform measure on $G \times G$:
$$I_{G\times G}\big(\chi\cdot\chi;\ (T\circ \mathrm{pr}_1, T\circ\mathrm{pr}_2)\big) = 1.$$
In particular this holds for $S_3 \times S_3$ with the cycle types.

*Proof.* The pair character is a homomorphism. It is surjective because $(g_0, 1) \mapsto \chi(g_0)$. It factors through $(T(g), T(h))$ because each of $\chi(g)$ and $\chi(h)$ does. Apply Theorem 3.1 on $G \times G$. $\square$

**Proposition 3.5 (One bit is the ceiling).** For any finite group $G$, any surjective $\chi: G \to \{\pm1\}$ and any function $T$ on $G$, we have $I_G(\chi;T) \le 1$.

*Proof.* $I = H(\chi) - H(\chi\mid T) = 1 - H(\chi \mid T) \le 1$, because conditional entropy is a non-negative combination of entropies. $\square$

The ceiling can fail to be reached. In $S_3$, the type "does $g$ fix the letter $1$?" carries $0$ bits about the sign. The two permutations fixing $1$ (the identity and one transposition) have opposite signs. The four permutations moving $1$ are two transpositions and two 3-cycles, so they are balanced as well.

**Theorem 3.6 (Independent coordinates are flat).** Let $s$ and $t$ be finite sets, $g$ a function on $s$ and $k$ a function on $t$. Under the uniform measure on $s \times t$,
$$I_{s\times t}\big(g\circ \mathrm{pr}_1;\ k \circ \mathrm{pr}_2\big) = 0.$$

*Proof sketch.* If either set is empty, everything vanishes. Otherwise, first show $H_{s\times t}(g\circ\mathrm{pr}_1) = H_s(g)$. The fibre of $g \circ \mathrm{pr}_1$ through $(a,b)$ is $g^{-1}(g(a)) \times t$, so each logarithm in the defining sum picks up an extra $\log_2|t|$, and this cancels against $\log_2|s\times t| = \log_2|s| + \log_2|t|$. Next, the fibre of $k\circ\mathrm{pr}_2$ over a value $c$ is $s \times t_c$, where $t_c = k^{-1}(c)$. By the same computation, $H_{s\times t_c}(g\circ\mathrm{pr}_1) = H_s(g)$. So
$$H(g\circ\mathrm{pr}_1 \mid k\circ\mathrm{pr}_2) = \sum_c \frac{|s||t_c|}{|s||t|}\,H_s(g) = H_s(g),$$
since the $|t_c|$ sum to $|t|$. The mutual information is therefore $H_s(g) - H_s(g) = 0$. $\square$

**Corollary 3.7 (Coprime moduli are flat, group form).** For any finite set $C$, under the uniform measure on $S_3 \times C$, the second coordinate carries zero information about the cycle type of the first. When an $S_3$-field $K$ is linearly disjoint from an abelian field $L$ with group $C$ (for instance a cyclotomic field $\mathbb{Q}(\zeta_m)$ meeting $K$ only in $\mathbb{Q}$), the Frobenius of the compositum lives in $S_3\times C$. In that case the residue class of $p$ in $C$ is independent of the splitting type.

---

## 4. Stickelberger's parity law for cubics

We now turn to arithmetic: which condition on $p$ decides the sign of Frobenius?

### 4.1 The reducible case, over any field

Let $F$ be a field.

**Proposition 4.1 (Factor and discriminant identities).** If $f_{a,b}(r) = 0$, then
$$f_{a,b}(x) = (x - r)\big(x^2 + rx + (a + r^2)\big), \qquad \Delta(a,b) = (-3r^2 - 4a)(3r^2 + a)^2.$$

*Proof.* Substitute $b = -r^3 - ar$ and expand. $\square$

The factor $-3r^2 - 4a = r^2 - 4(a + r^2)$ is the discriminant of the residual quadratic. So *$\Delta$ equals the discriminant of the residual quadratic times a square.*

**Theorem 4.2 (Sign law, reducible case).** Let $\operatorname{char} F \neq 2$. Suppose $f_{a,b}$ has a root $r \in F$ and $\Delta = \Delta(a,b) \ne 0$. Then
$$\Delta \text{ is a square in } F \iff f_{a,b} \text{ has a root } s \in F \text{ with } s \neq r.$$

*Proof.* Since $\Delta \ne 0$, Proposition 4.1 gives $m := 3r^2 + a \neq 0$.

($\Rightarrow$) Suppose $t^2 = \Delta$. Put $u = t/m$. Then $u^2 = -3r^2 - 4a$, so $s = (u - r)/2$ is a root of the residual quadratic (quadratic formula), and hence a root of $f_{a,b}$. If $s = r$, then $u = 3r$, so $9r^2 = -3r^2 - 4a$, that is $4m = 0$. Since $4 = 2 \cdot 2 \neq 0$, this contradicts $m \ne 0$.

($\Leftarrow$) If $s \neq r$ is a root, the factorisation shows $s^2 + rs + (a + r^2) = 0$. Then $(2s + r)^2 = 4(s^2 + rs) + r^2 = -3r^2 - 4a$, so
$$\Delta = \big((2s + r)(3r^2 + a)\big)^2. \qquad\square$$

**Corollary 4.3.** Let $\operatorname{char} F \neq 2$. If $f_{a,b}$ has a root $r$ and $\Delta$ is not a square, then $r$ is the only root: the splitting type is $1 + 2$. (Here no hypothesis $\Delta\ne0$ is needed, because $0$ is a square.)

### 4.2 The irreducible case over $\mathbb{F}_p$

**Lemma 4.4 (Frobenius-fixed elements are rational).** Let $K$ be a field extension of $\mathbb{F}_p$. If $x \in K$ satisfies $x^p = x$, then $x \in \mathbb{F}_p$.

*Proof.* Every element of $\mathbb{F}_p$ is a root of $X^p - X$ by Fermat's little theorem. If $x \notin \mathbb{F}_p$, then $X^p - X$ would have at least $p + 1$ distinct roots in $K$. That is impossible for a nonzero polynomial of degree $p$. $\square$

**Theorem 4.5 (Frobenius 3-cycle).** Let $a, b \in \mathbb{F}_p$, and suppose $f_{a,b}$ has no root in $\mathbb{F}_p$ but has a root $r$ in some extension field $K \supseteq \mathbb{F}_p$. Then $\Delta(a,b)$ is a square in $\mathbb{F}_p$.

*Proof.* Let $\varphi(x) = x^p$ be the Frobenius endomorphism of $K$. It is a ring homomorphism fixing $\mathbb{F}_p$, so it maps roots of $f = f_{a,b}$ to roots. It fixes no root, since by Lemma 4.4 a fixed root would lie in $\mathbb{F}_p$.

Put $r_1 = r$ and $r_2 = \varphi(r_1) \neq r_1$. Subtracting $f(r_1) = 0$ from $f(r_2) = 0$ and dividing by $r_1 - r_2$ gives $r_1^2 + r_1r_2 + r_2^2 + a = 0$. With $r_3 = -r_1 - r_2$ we get $f(x) = (x-r_1)(x-r_2)(x-r_3)$ in $K[x]$.

Let $s = \varphi(r_2)$. It is a root, and $s \ne r_2$. If $s = r_1$, then $\varphi(r_3) = -r_2 - r_1 = r_3$, so $r_3$ would be a fixed root, which is impossible. Hence $s = r_3$ and $\varphi(r_3) = r_1$. So $\varphi$ acts on the roots as the 3-cycle $r_1 \to r_2 \to r_3 \to r_1$.

The Vandermonde product $\delta = (r_1 - r_2)(r_1 - r_3)(r_2 - r_3)$ satisfies $\delta^2 = \Delta$ (a direct expansion using $a = -(r_1^2 + r_1r_2 + r_2^2)$ and $b = -r_1^3 - ar_1$). A 3-cycle is an even permutation, so $\varphi(\delta) = \delta$. By Lemma 4.4, $\delta \in \mathbb{F}_p$, and so $\Delta = \delta^2$ is a square in $\mathbb{F}_p$. $\square$

A root in some extension always exists: take $K = \mathbb{F}_p[x]/(f)$, which is a field because a cubic without roots over a field is irreducible. Thus:

**Corollary 4.6 (Irreducible case).** If $f_{a,b}$ has no root in $\mathbb{F}_p$, then $\Delta(a,b)$ is a square in $\mathbb{F}_p$. No separability hypothesis is needed.

**Theorem 4.7 (Sign Law over $\mathbb{F}_p$; Stickelberger's parity law for cubics).** Let $p$ be an odd prime and $a, b \in \mathbb{F}_p$ with $\Delta = \Delta(a,b) \ne 0$. Then
$$\Delta \text{ is a non-square in } \mathbb{F}_p \iff f_{a,b} \text{ has exactly one root in } \mathbb{F}_p.$$

*Proof.* Since $p$ is odd, $2 \ne 0$ in $\mathbb{F}_p$.

($\Rightarrow$) If $f$ has a root, it is unique by Corollary 4.3. If $f$ has no root, Corollary 4.6 makes $\Delta$ a square, which contradicts the hypothesis.

($\Leftarrow$) If $f$ has exactly one root $r$ and $\Delta$ were a square, Theorem 4.2 would produce a second root. $\square$

In the language of Section 3: when $p \nmid \Delta$, the sign of Frobenius equals the quadratic character $\left(\frac{\Delta}{p}\right)$. So the sign character of the splitting field is the quadratic character of the discriminant. This is what attaches a *conductor* to the sign bit.

---

## 5. The pure cubic $x^3 - 2$: conductor $3$

Here $a = 0$, $b = -2$, and $\Delta = -108 = -3\cdot 6^2$.

**Proposition 5.1 (Cubing is bijective when $p \equiv 2 \bmod 3$).** If $p \equiv 2 \pmod 3$, then $x \mapsto x^3$ is a bijection of $\mathbb{F}_p$. Hence $x^3 = a$ has exactly one root for every $a \in \mathbb{F}_p$.

*Proof.* For every $x \in \mathbb{F}_p$, we have $x^{2p-1} = x$: this is clear for $x = 0$, and otherwise $x^{2p-1} = x^p\cdot x^{p-1} = x \cdot 1$. Since $p \equiv 2 \pmod 3$, $3 \mid 2p - 1$, say $2p - 1 = 3k$. If $x^3 = y^3$, then $x = (x^3)^k = (y^3)^k = y$. An injective self-map of a finite set is bijective. $\square$

**Proposition 5.2 (Zero or three roots when $p \equiv 1 \bmod 3$).** If $p \equiv 1 \pmod 3$ and $a \ne 0$, then $x^3 = a$ has either $0$ or $3$ roots in $\mathbb{F}_p$.

*Proof.* The cyclic group $\mathbb{F}_p^\times$ has order divisible by $3$, so it contains an element $\omega$ of order $3$, which satisfies $\omega^2 + \omega + 1 = 0$. If $x^3 = a$, then $x, \omega x, \omega^2x$ are three distinct roots, since $x \neq 0$. A cubic has at most three roots. $\square$

**Theorem 5.3 (Pure Cubic Theorem).** For every prime $p > 3$:
$$\#\{x \in \mathbb{F}_p : x^3 = 2\} = 1 \iff p \equiv 2 \pmod 3.$$

*Proof.* A prime $p > 3$ is $\equiv 1$ or $2 \pmod 3$. If $p \equiv 2$, apply Proposition 5.1. If $p \equiv 1$, Proposition 5.2 with $a = 2 \ne 0$ excludes exactly one root. $\square$

**Theorem 5.4 (The quadratic character of $-3$, from the cubic).** For every prime $p > 3$, $-3$ is a square in $\mathbb{F}_p$ iff $p \equiv 1 \pmod 3$.

*Proof.* ($\Leftarrow$) With $\omega$ as in Proposition 5.2, $(2\omega + 1)^2 = 4(\omega^2 + \omega) + 1 = -3$.

($\Rightarrow$) Suppose $t^2 = -3$ but $p \equiv 2 \pmod 3$. By Proposition 5.1 there is a unique $r$ with $r^3 = 2$, a root of $f_{0,-2}$. Its discriminant $-3\cdot 6^2 = (6t)^2$ is a nonzero square, since $2, 3 \ne 0$. Theorem 4.2 then produces a second root $s \ne r$ with $s^3 = 2$. This contradicts the injectivity of cubing. $\square$

Combining Theorem 5.3 with Theorem 4.7 gives the sign law in its discriminant form: for $p \notin \{2,3\}$, $x^3 - 2$ has exactly one root mod $p$ iff $-108$ is a non-square mod $p$, iff $p \equiv 2 \pmod 3$.

**Theorem 5.5 (The pure-cubic channel).** Let $T(p) = \#\{x \in \mathbb{F}_p : x^3 = 2\}$. For every finite set $S$ of primes $> 3$, the splitting type reveals $p \bmod 3$ completely:
$$I_S(p \bmod 3;\ T) = H_S(p \bmod 3).$$
On the balanced sample $S = \{5, 7, 11, 13\}$ this is exactly $1$ bit.

*Proof.* By Theorem 5.3, for primes $p, q > 3$, $T(p) = T(q)$ implies $p \equiv q \pmod 3$. Lemma 2.3 gives the first claim. On $\{5,7,11,13\}$ the residues are $2,1,2,1$, so both fibres have size $2$, and Lemma 2.2 gives $\log_2 4 - \log_2 2 = 1$. $\square$

**Theorem 5.6 (Semiprime pair channel for $x^3-2$).** For every finite set $S$ of pairs $(p,q)$ of primes $>3$,
$$I_S\big(pq \bmod 3;\ (T(p), T(q))\big) = H_S(pq \bmod 3).$$
On $S = \{5, 7\}^2$ this is exactly $1$ bit.

*Proof.* The pair of types determines $p \bmod 3$ and $q \bmod 3$, hence $pq \bmod 3$. On $\{5,7\}^2$, the products $25, 35, 35, 49$ are $\equiv 1, 2, 2, 1 \pmod 3$: two fibres of size $2$. $\square$

---

## 6. The trinomial $x^3 + x + 1$: conductor $31$

Here $a = b = 1$ and $\Delta = -4 - 27 = -31$.

**Theorem 6.1 (Sign law for the trinomial).** For every prime $p \notin \{2, 31\}$, $x^3 + x + 1$ has exactly one root in $\mathbb{F}_p$ iff $-31$ is a non-square in $\mathbb{F}_p$.

*Proof.* This is Theorem 4.7 with $\Delta = -31 \neq 0$ in $\mathbb{F}_p$. $\square$

**Lemma 6.2 (Quadratic reciprocity for $-31$).** For every odd prime $p \neq 31$, $\left(\frac{-31}{p}\right) = \left(\frac{p}{31}\right)$.

*Proof.* We have $\left(\frac{-31}{p}\right) = \left(\frac{-1}{p}\right)\left(\frac{31}{p}\right)$. Reciprocity gives $\left(\frac{31}{p}\right) = \left(\frac{p}{31}\right)(-1)^{\frac{p-1}{2}\cdot 15} = \left(\frac{p}{31}\right)\left(\frac{-1}{p}\right)$, and the two factors $\left(\frac{-1}{p}\right)$ cancel. $\square$

**Theorem 6.3 (Trinomial Theorem).** For every prime $p \notin \{2, 31\}$:
$$x^3 + x + 1 \text{ has exactly one root mod } p \iff \left(\frac{p}{31}\right) = -1.$$

**Corollary 6.4 (Conductor 31).** If $p, q \notin \{2,31\}$ are primes with $p \equiv q \pmod{31}$, then $x^3+x+1$ has exactly one root mod $p$ iff it has exactly one root mod $q$.

**Theorem 6.5 (The trinomial channel lives at conductor 31).** Let $T'(p)$ be the number of roots of $x^3 + x + 1$ in $\mathbb{F}_p$. For every finite set $S$ of primes outside $\{2, 31\}$,
$$I_S\big(\left(\tfrac{p}{31}\right);\ T'\big) = H_S\big(\left(\tfrac{p}{31}\right)\big).$$

*Proof.* The Legendre symbol takes the values $\pm1$ on $S$. By Theorem 6.3 its value is $-1$ exactly when $T'(p) = 1$, so it is a function of $T'$. Apply Lemma 2.3. $\square$

**Theorem 6.6 (Conductor separation).** We have
1. $5 \equiv 11 \equiv 2 \pmod 3$;
2. $x^3 + x + 1$ has no root mod $5$ (its Frobenius is a 3-cycle, which is even) and exactly one root mod $11$, namely $x = 2$ (its Frobenius is a transposition, which is odd);
3. $x^3 - 2$ has exactly one root both mod $5$ and mod $11$.

Consequently the sign bit of $x^3+x+1$ is **not** a function of $p \bmod 3$. On the sample $\{5, 11\}$,
$$I\big(p \bmod 3;\ T'\big) = 0 \text{ bits}, \qquad I\big(\left(\tfrac{p}{31}\right);\ T'\big) = 1 \text{ bit}.$$

*Proof.* Items 1–3 are finite checks: modulo $5$, $f(0),\dots,f(4) = 1, 3, 1, 1, 4$; modulo $11$ the unique root is $x = 2$. For the channels: $p \bmod 3$ is constant on $\{5,11\}$, so its entropy is $0$ and so is the mutual information. Next, $\left(\frac{5}{31}\right) = 1$ because $6^2 = 36 \equiv 5$, and $\left(\frac{11}{31}\right) = -1$. So the Legendre symbol has two singleton fibres and entropy $\log_2 2 = 1$, and Theorem 6.5 turns this into mutual information. $\square$

The zero on $\{5,11\}$ is the smallest possible witness, and it comes from the input variable being constant on the sample. The substantive point is item 2: two primes with the same residue mod $3$ have Frobenius elements of opposite sign. Read backwards, the splitting type mod $11$ also certifies that $-31$ is a non-square mod $11$.

---

## 7. Algorithms

The results suggest three simple procedures, which we used for the numerical experiments in Section 8.

### Algorithm A: Splitting type and sign bit of a depressed cubic

*Input:* integers $a, b$ and an odd prime $p \nmid \Delta(a,b)$. *Output:* splitting type and sign of Frobenius.

1. Count $n = \#\{x \in \mathbb{F}_p : x^3 + ax + b \equiv 0\}$. Brute force costs $O(p)$; alternatively $n = \deg\gcd(f, x^p - x)$ can be computed in $O(\log p)$ polynomial operations.
2. The splitting type is $1+1+1$, $1+2$ or $3$ according as $n = 3, 1, 0$.
3. Set the sign to $-1$ if $n = 1$, else $+1$.
4. (Certificate.) Compute $\left(\frac{\Delta}{p}\right) = \Delta^{(p-1)/2} \bmod p$ by fast exponentiation in $O(\log p)$ multiplications. By Theorem 4.7 it must equal the sign.

### Algorithm B: Empirical type-channel mutual information

*Input:* a finite list $S$ and two functions $g, k$. *Output:* $I_S(g;k)$.

1. Tally the counts of $g$-values and compute $H_S(g)$.
2. Group $S$ into the fibres of $k$. For each fibre, compute the entropy of $g$ on it and weight it by the fibre's relative size.
3. Return $H_S(g) - H_S(g \mid k)$.

This takes $O(|S|)$ time with hashing.

### Algorithm C: Conductor detection

*Input:* a sign-bit function $\sigma$ on primes and a sample $P$. *Output:* the smallest $m \le M$ such that $\sigma$ is a function of $p \bmod m$ on $P$.

For $m = 1, 2, \dots, M$: build the map from residue $r$ to the set of values $\{\sigma(p) : p \in P,\ p \equiv r \bmod m\}$, and return $m$ if every set is a singleton. On a large sample this returns $3$ for $x^3-2$ and $31$ for $x^3+x+1$, as predicted by Theorems 5.3 and 6.2. A sample can only give an upper bound for the true conductor; the theorems supply the proof that the returned modulus actually works.

---

## 8. Numerical illustration

The following figures were computed directly (brute-force root counting and Euler's criterion). They illustrate the theorems above.

*Splitting types for small primes.*

| $p$ | $p \bmod 3$ | $p \bmod 31$ | $x^3-2$ | $x^3+x+1$ |
|---|---|---|---|---|
| 5 | 2 | 5 | $1+2$ (root 3) | $3$ |
| 7 | 1 | 7 | $3$ | $3$ |
| 11 | 2 | 11 | $1+2$ (root 7) | $1+2$ (root 2) |
| 13 | 1 | 13 | $3$ | $1+2$ (root 7) |
| 43 | 1 | 12 | $1+1+1$ (roots 20, 32, 34) | $1+2$ (root 38) |
| 47 | 2 | 16 | $1+2$ (root 21) | $1+1+1$ (roots 25, 34, 35) |

*Sign law.* For six depressed cubics with discriminants $-108, -31, -23, -275, 697, -3375$, we checked every prime up to $2000$ not dividing $2\Delta$ (about $300$ primes each). There were no violations of "one root $\iff \left(\frac{\Delta}{p}\right) = -1$".

*Channels on all $427$ primes up to $3000$ (excluding $2, 3, 31$).* Here $I(\text{sign bit}; p \bmod m)$ is:

| $m$ | $x^3-2$ | $x^3+x+1$ |
|---|---|---|
| 3 | 0.9991 | 0.0000 |
| 4 | 0.0005 | 0.0002 |
| 5 | 0.0028 | 0.0080 |
| 12 | 0.9991 | 0.0010 |
| 31 | 0.0133 | 0.9995 |
| 93 | 0.9991 | 0.9995 |

The full entropy of the sign bit ($0.9991$ and $0.9995$ bits on this sample) is recovered exactly when the modulus is a multiple of the conductor. Unrelated moduli give small positive values. These are finite-sample fluctuations, consistent with the exact vanishing of Theorem 3.6 in the limit.

*Chebotarev frequencies.* Among the primes $p \le 20000$ with $p > 3$ and $p\nmid\Delta$, the types $1+1+1 : 1+2 : 3$ occur with frequencies $0.163 : 0.503 : 0.335$ for $x^3 - 2$ and $0.160 : 0.506 : 0.333$ for $x^3+x+1$. The $S_3$ prediction is $0.167 : 0.500 : 0.333$.

---

## 9. Discussion

**Shape versus address.** The results separate two layers that are easy to conflate. The *shape* of the type channel — its capacity of one bit, the fact that the cycle type reaches that capacity, and the pair and flatness laws — is a statement about the uniform measure on a finite group. By Chebotarev it is inherited by every Galois extension with that group. In this sense the law is universal, and Theorem 3.1 shows it is universal well beyond $S_3$.

The *address* of the sign character is a different matter. By this we mean the modulus $m$ such that $\operatorname{sgn}(\mathrm{Frob}_p)$ is a function of $p \bmod m$. The sign character cuts out the quadratic subfield $\mathbb{Q}(\sqrt{\Delta})$ of the $S_3$-field, and Theorem 4.7 identifies it with the quadratic character of $\Delta$. By quadratic reciprocity, this is a Dirichlet character whose conductor is that of $\mathbb{Q}(\sqrt\Delta)$. For $x^3-2$, $\mathbb{Q}(\sqrt{-108}) = \mathbb{Q}(\sqrt{-3})$ has conductor $3$. For $x^3 + x + 1$, $\mathbb{Q}(\sqrt{-31})$ has conductor $31$. The address is determined by the field, not the group.

**The original claim, corrected.** "$I(p \bmod 3; T) = 1$ exactly" is a correct statement for $x^3-2$. On any balanced sample it follows from Theorem 5.5, and asymptotically the residue $p \bmod 3$ is balanced among primes by Dirichlet's theorem. For $x^3 + x + 1$ the same statement is false: Theorem 6.6 exhibits two primes with the same residue mod $3$ and opposite signs. What does transfer from one field to the other is the statement at the level of the group, $I(\operatorname{sgn}; T) = 1$, together with its reading at each field's own conductor.

**Elementary methods.** Every arithmetic step above uses only Fermat's little theorem, root counting for polynomials over a field, the existence of $\mathbb{F}_p[x]/(f)$, and quadratic reciprocity. The Frobenius argument of Theorem 4.5 is Galois theory in miniature: we never construct the Galois group, only the orbit of one root under $x\mapsto x^p$.

---

## 10. Future directions

1. **Conductor-of-the-sign law for all $S_3$ cubics.** For every irreducible cubic $f \in \mathbb{Z}[x]$ with group $S_3$ and discriminant $D$, the sign bit "exactly one root mod $p$" should be a function of $p \bmod |D_0|$ and of no smaller modulus, where $D_0$ is the fundamental discriminant of $\mathbb{Q}(\sqrt{D})$. The sign law and quadratic reciprocity turn the sign bit into the Kronecker character $\left(\frac{D_0}{\cdot}\right)$, whose exact conductor is $|D_0|$. What remains is the Tschirnhaus reduction to depressed form and the minimality claim.
2. **Full Stickelberger theorem.** For a separable $f \in \mathbb{F}_p[x]$ of degree $n$ with $r$ irreducible factors, $\operatorname{disc}(f)$ should be a square iff $n - r$ is even. The Vandermonde argument of Theorem 4.5 extends once Frobenius is seen as a product of cycles, one for each irreducible factor.
3. **Type channels see exactly the abelianization.** For a finite group $G$ and $T$ = conjugacy class, every one-dimensional character $\chi$ of $G$ factors through $T$, so Lemma 2.3 and Proposition 2.4 give $I(\chi; T) = \log_2|\chi(G)|$. The natural conjecture is that the characters fully visible to the type channel in this sense are exactly those that factor through the abelianization $G^{\mathrm{ab}}$. The companion arithmetic question is to determine, for each such character, the conductor at which it can be read.

---

## Appendix: the discriminant identity

For completeness, with $b = -r^3 - ar$:
$$-4a^3 - 27(r^3 + ar)^2 = -4a^3 - 27r^6 - 54ar^4 - 27a^2r^2,$$
$$(-3r^2 - 4a)(3r^2 + a)^2 = (-3r^2 - 4a)(9r^4 + 6ar^2 + a^2) = -27r^6 - 54ar^4 - 27a^2r^2 - 4a^3.$$
The two expressions agree.
