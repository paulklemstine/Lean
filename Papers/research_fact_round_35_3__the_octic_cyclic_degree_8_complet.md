# Full Pinning at Degree Eight: The Octic Real Cyclotomic Field $\mathbb{Q}(\zeta_{17})^+$ and the Real-Cyclotomic Entropy Ladder at Every Degree

**Aristotle**

*October 2026*

---

## Abstract

For an odd prime $f$, let $T$ be the residue degree of a prime $p \nmid f$ in the real cyclotomic field $\mathbb{Q}(\zeta_f)^+$, viewed as a function of the residue class $u = p \bmod f$ under the uniform distribution on $(\mathbb{Z}/f)^\times$. Write $\mathcal{H}(n)$ for the Shannon entropy of the order of a uniformly random element of the cyclic group $C_n$. We prove that
$$H(T) = \mathcal{H}\!\left(\tfrac{f-1}{2}\right)$$
for **every** odd prime $f$. Earlier versions of this "real-cyclotomic ladder" required the degree $(f-1)/2$ to be prime. The proof rests on one elementary principle: counting entropy is invariant under uniform covers. It is applied twice, once along the discrete logarithm (a bijection) and once along the two-to-one sign fold $(\mathbb{Z}/f)^\times \to (\mathbb{Z}/f)^\times/\{\pm 1\}$. The same argument gives an exact type-count law: exactly $2\varphi(d)$ classes mod $f$ have residue degree $d$, for each $d \mid (f-1)/2$. For two-power degrees we obtain the closed form $\mathcal{H}(2^m) = 2 - 2^{1-m}$, so every Fermat prime $f = 2^{m+1}+1$ has $H(T) = 2 - 2^{1-m}$.

The octic field $\mathbb{Q}(\zeta_{17})^+$ (Galois group $C_8$, conductor $17$) is the first Fermat rung of composite degree. For it we prove:

- the splitting law in congruence form;
- the type census $\{1:2,\,2:2,\,4:4,\,8:8\}$ over the sixteen classes mod 17, i.e. densities $\tfrac18,\tfrac18,\tfrac14,\tfrac12$;
- the exact value $H(T) = 7/4$ bits;
- full pinning, $I(p \bmod 17;\, T) = H(T)$;
- the tower filtration $I(T;\text{layer}_j) = 1,\ 3/2,\ 7/4$ for the subfields of degree $2, 4, 8$.

The experimentally reported entropy $1.7474$ lies strictly below $7/4$ and within $0.003$ of it, the expected sign of a plug-in estimate. Finally, in the $C_8$ exponent model the semiprime type-pair channel carries exactly $21/16$ bits, and the ordered pair carries no extra information: the which-factor increment is exactly zero.

---

## 1. Introduction

### 1.1 Splitting types as random variables

Let $K/\mathbb{Q}$ be an abelian number field of conductor $f$. By class field theory, the way an unramified prime $p$ decomposes in $K$ is governed by its Frobenius element. That element depends only on $p \bmod f$ through the Artin map $(\mathbb{Z}/f)^\times \twoheadrightarrow \operatorname{Gal}(K/\mathbb{Q})$. In particular the **residue degree** of $p$, the common degree of the residue fields of the primes above $p$, equals the order of the Frobenius in the Galois group.

By Dirichlet's theorem, primes are equidistributed among the classes of $(\mathbb{Z}/f)^\times$. So the residue degree of a "random prime" is, in density, a random variable on the finite set $(\mathbb{Z}/f)^\times$ with the uniform distribution. Two quantities attached to it are natural:

1. its **Shannon entropy** $H(T)$, which measures the arithmetic variety of splitting in $K$;
2. the **mutual information** $I(X;T)$ between $T$ and a computable observable $X$ of $p$, such as $p \bmod f$, a Legendre symbol, or the Frobenius in a subfield. This measures how much of the splitting behaviour the observable explains.

When $I(X;T) = H(T)$ we say that $X$ **fully pins** $T$.

### 1.2 The real cyclotomic ladder and the gap at degree 8

The real cyclotomic field $\mathbb{Q}(\zeta_f)^+ = \mathbb{Q}(\zeta_f + \zeta_f^{-1})$ for an odd prime $f$ has Galois group $(\mathbb{Z}/f)^\times/\{\pm1\}$, cyclic of order $(f-1)/2$. An earlier form of the *real-cyclotomic ladder* identified $H(T)$ for this field with the order-type entropy of the abstract cyclic group of order $(f-1)/2$, but only when $(f-1)/2$ is **prime**, i.e. for $f = 5, 7, 11, 23, 47, \dots$. The octic field $\mathbb{Q}(\zeta_{17})^+$, with $(17-1)/2 = 8$, is not covered by that statement.

An experimental study of the octic field reported:

- an entropy estimate $H(T) \approx 1.7474$ bits;
- $I(p \bmod 17;\, T) \approx H(T)$ (full pinning);
- four types with frequencies $\{1 : 12\%,\ 2 : 12\%,\ 4 : 25\%,\ 8 : 50\%\}$;
- a semiprime pair channel of about $1.3097$ bits, with a "which-factor" increment of about $0.0002$.

### 1.3 Contributions

This paper puts these observations on an exact footing and removes the primality restriction.

1. **Uniform-cover invariance** (Theorem 2.3). Counting entropy does not change when a read-out is pulled back along a map whose fibres all have the same size.
2. **The real-cyclotomic ladder at every degree** (Theorem 3.4). $H(T) = \mathcal{H}((f-1)/2)$ for every odd prime $f$.
3. **The type-count law** (Theorem 3.5). $\#\{u : T(u) = d\} = 2\varphi(d)$ for every $d \mid (f-1)/2$.
4. **The two-power ladder** (Theorem 4.2). $\mathcal{H}(2^m) = 2 - 2^{1-m}$, with the Fermat-rung corollary $H(T) = 2 - 2^{1-m}$ for $f = 2^{m+1}+1$.
5. **The octic rung** (Section 5). The splitting law, the census, $H(T) = 7/4$, full pinning, and the quantitative comparison with the reported value.
6. **The octic tower** (Section 6). The information $1$, $3/2$, $7/4$ carried by the subfields of degree $2$, $4$, $8$, and the fact that the Legendre symbol does not pin.
7. **The octic semiprime channel** (Section 7). Exactly $21/16$ bits, and a which-factor increment of exactly $0$.

All proofs are elementary and finite. Beyond the classical description of Frobenius in cyclotomic fields, no analytic input is needed.

---

## 2. Counting entropy and uniform covers

### 2.1 Definitions

Throughout, $\log_2$ is the binary logarithm and $|A|$ is the cardinality of a finite set.

**Definition 2.1 (Counting entropy).** Let $S$ be a nonempty finite set and $g : S \to Y$ any map. The *counting entropy* of $g$ on $S$ is
$$H_S(g) = \log_2 |S| - \frac{1}{|S|}\sum_{a \in S} \log_2 \big|\{x \in S : g(x) = g(a)\}\big|,$$
and $H_\emptyset(g) = 0$. Grouping the sum by fibres shows that $H_S(g) = -\sum_y q_y \log_2 q_y$ with $q_y = |g^{-1}(y)|/|S|$. So $H_S(g)$ is the Shannon entropy of $g(a)$ for $a$ uniform on $S$.

**Definition 2.2 (Conditional entropy, mutual information).** For maps $g, x$ on $S$,
$$H_S(g \mid x) = \sum_{y \in x(S)} \frac{|x^{-1}(y)|}{|S|}\, H_{x^{-1}(y)}(g), \qquad I_S(g; x) = H_S(g) - H_S(g \mid x).$$

Two elementary facts are used repeatedly.

- **Determination.** If $x(a) = x(b)$ implies $g(a) = g(b)$, every fibre of $x$ carries a constant read-out, so $H_S(g \mid x) = 0$ and $I_S(g; x) = H_S(g)$. In particular this holds when $x$ is injective.
- **Fibre formula.** If $g$ takes the value $y_i$ on a fibre of size $c_i$ ($i = 1, \dots, r$), then $H_S(g) = \log_2|S| - \frac{1}{|S|}\sum_i c_i \log_2 c_i$.

### 2.2 The uniform-cover lemma

**Lemma 2.3 (Counting through a uniform cover).** Let $\phi : S \to T$ be a map of finite sets with $\phi(S) \subseteq T$, and suppose every fibre has the same size: $|\{a \in S : \phi(a) = b\}| = c$ for all $b \in T$. Then for every predicate $P$ on $T$,
$$\big|\{a \in S : P(\phi(a))\}\big| = c\cdot\big|\{b \in T : P(b)\}\big|,$$
and in particular $|S| = c\,|T|$.

*Proof.* Partition $\{a : P(\phi(a))\}$ by the value $b = \phi(a) \in T$. The block over $b$ is the whole fibre of $b$, of size $c$, if $P(b)$ holds, and is empty otherwise. Summing over $b$ gives the claim. Taking $P$ identically true gives $|S| = c|T|$. $\square$

**Theorem 2.4 (Entropy is invariant under uniform covers).** Under the hypotheses of Lemma 2.3 with $c > 0$, for every read-out $h : T \to Z$,
$$H_S(h \circ \phi) = H_T(h).$$

*Proof sketch.* By Lemma 2.3 applied to $P(b) := [h(b) = h(\phi(a))]$, the $h\circ\phi$-fibre of $a$ has size $c\cdot m(\phi(a))$, where $m(b) = |\{y \in T : h(y) = h(b)\}|$. Grouping $\sum_{a\in S}$ by the value $\phi(a) = b$, each $b$ occurring exactly $c$ times, gives
$$\sum_{a \in S}\log_2\big(c\,m(\phi(a))\big) = c\sum_{b\in T}\log_2\big(c\,m(b)\big) = c\Big(|T|\log_2 c + \sum_{b \in T} \log_2 m(b)\Big).$$
Since $|S| = c|T|$,
$$H_S(h\circ\phi) = \log_2(c|T|) - \frac{c|T|\log_2 c + c\sum_b \log_2 m(b)}{c|T|} = \log_2|T| - \frac{1}{|T|}\sum_{b\in T}\log_2 m(b) = H_T(h).$$
The empty case $T = \emptyset$ forces $S = \emptyset$ and both sides vanish. $\square$

Two instances matter below: a **bijection** ($c = 1$) and a **two-to-one fold** ($c = 2$). The content of Theorem 2.4 is that the factor $c$ cancels: scaling every fibre by $c$ scales every probability's numerator and denominator alike.

---

## 3. The real-cyclotomic ladder at every degree

### 3.1 The cyclic type model

**Definition 3.1 (Order type, type entropy).** For $n \ge 1$ and $a \in \mathbb{Z}_{\ge 0}$, let
$$\operatorname{ord}_n(a) = \frac{n}{\gcd(a, n)},$$
the order of $a \bmod n$ in the additive cyclic group $C_n = \mathbb{Z}/n$. In particular $\operatorname{ord}_n(0) = 1$, and $\operatorname{ord}_n(a)$ depends only on $a \bmod n$. The **type entropy** of $n$ is
$$\mathcal{H}(n) = H_{\{0,1,\dots,n-1\}}(\operatorname{ord}_n),$$
the entropy of the order of a uniformly random element of $C_n$.

Since $C_n$ has exactly $\varphi(d)$ elements of order $d$ for every $d \mid n$, the fibre formula gives the **$\varphi$-law**
$$\mathcal{H}(n) = \sum_{d \mid n} \frac{\varphi(d)}{n}\log_2\frac{n}{\varphi(d)}. \tag{3.1}$$
For example $\mathcal{H}(8) = \tfrac18\log_2 8 + \tfrac18\log_2 8 + \tfrac28\log_2 4 + \tfrac48\log_2 2 = 7/4$.

### 3.2 The arithmetic type

Fix an odd prime $f$ and let $\Sigma = \{\pm 1\} \le (\mathbb{Z}/f)^\times$ be the sign subgroup.

**Definition 3.2 (Real residue degree).** For $u \in (\mathbb{Z}/f)^\times$, let $T_f(u)$ be the order of the coset $u\Sigma$ in the quotient $G_f = (\mathbb{Z}/f)^\times/\Sigma$. Equivalently, $T_f(u)$ is the least $k \ge 1$ with $u^k \equiv \pm 1 \pmod f$.

By the classical description of Frobenius in cyclotomic fields, $G_f \cong \operatorname{Gal}(\mathbb{Q}(\zeta_f)^+/\mathbb{Q})$, with $u\Sigma$ the Frobenius of any prime $p \equiv u$. So $T_f(p \bmod f)$ is the residue degree of $p$ in $\mathbb{Q}(\zeta_f)^+$, and $p$ splits into $\frac{f-1}{2}/T_f(p)$ primes there. All statements below concern the function $T_f$ on $(\mathbb{Z}/f)^\times$ with the uniform distribution, which by Dirichlet's theorem is the density distribution of primes. We write $H(T) := H_{(\mathbb{Z}/f)^\times}(T_f)$.

Two immediate facts:

- **Sign invariance.** $T_f(-u) = T_f(u)$, since $u$ and $-u$ have the same coset.
- **The $\pm1$-criterion.** For every $d \ge 1$: $T_f(u) \mid d \iff u^d = \pm 1$ in $(\mathbb{Z}/f)^\times$. Indeed, $T_f(u) \mid d$ iff $(u\Sigma)^d = 1$ in $G_f$ iff $u^d \in \Sigma$.

**Lemma 3.3 (Galois order).** $|G_f| = (f-1)/2$. If $g$ generates $(\mathbb{Z}/f)^\times$, then $g$ has order $f-1$, and its image $g\Sigma$ generates $G_f$ and has order $(f-1)/2$.

*Proof.* $|(\mathbb{Z}/f)^\times| = \varphi(f) = f-1$, and $|\Sigma| = 2$ because $f > 2$. The image of a generator generates the quotient, and the order of a generator of a cyclic group is the order of the group. $\square$

### 3.3 The arithmetic type is the exponent-model type

**Theorem 3.4 (Exponent model).** Let $f$ be an odd prime, $n = (f-1)/2$, and let $g$ be a primitive root mod $f$. Then for every $a \ge 0$,
$$T_f(g^a) = \operatorname{ord}_n(a).$$

*Proof.* Under the quotient map $\pi : (\mathbb{Z}/f)^\times \to G_f$ we have $\pi(g^a) = \pi(g)^a$. In any group, the order of $x^a$ is $\operatorname{ord}(x)/\gcd(a, \operatorname{ord}(x))$. By Lemma 3.3, $\operatorname{ord}(\pi(g)) = n$. $\square$

Thus, read through the discrete logarithm, the residue degree is the order type of the exponent reduced mod $n$. The factor $2$ between $f - 1$ and $n$ is the sign fold: $g^{n} = -1$.

### 3.4 The ladder theorem

**Theorem 3.5 (Real-cyclotomic ladder at every degree).** For every odd prime $f$,
$$H(T) = H_{(\mathbb{Z}/f)^\times}(T_f) = \mathcal{H}\!\left(\frac{f-1}{2}\right).$$
No primality hypothesis on $(f-1)/2$ is needed.

*Proof.* Let $g$ be a primitive root and $n = (f-1)/2$, so $f - 1 = 2n$.

*Step 1 (discrete logarithm, $c = 1$).* The map $\phi_1 : \{0, \dots, f-2\} \to (\mathbb{Z}/f)^\times$, $a \mapsto g^a$, is a bijection: $g$ has order $f-1$, so $g^a$, $0 \le a < f-1$, are pairwise distinct and exhaust the group. Every fibre is a singleton. By Theorem 2.4,
$$H_{(\mathbb{Z}/f)^\times}(T_f) = H_{\{0,\dots,2n-1\}}(T_f \circ \phi_1).$$

*Step 2 (rewrite).* By Theorem 3.4 and the fact that $\operatorname{ord}_n(a)$ depends only on $a \bmod n$, $T_f\circ\phi_1 = \operatorname{ord}_n \circ \phi_2$ with $\phi_2(a) = a \bmod n$.

*Step 3 (sign fold, $c = 2$).* The reduction $\phi_2 : \{0,\dots,2n-1\} \to \{0, \dots, n-1\}$ is exactly two-to-one: the fibre of $b$ is $\{b, b+n\}$. By Theorem 2.4,
$$H_{\{0,\dots,2n-1\}}(\operatorname{ord}_n\circ\phi_2) = H_{\{0,\dots,n-1\}}(\operatorname{ord}_n) = \mathcal{H}(n). \qquad\square$$

The two steps correspond to the two structural facts of the field: the unit group is cyclic (Step 1), and the real subfield cannot distinguish $u$ from $-u$ (Step 3).

**Theorem 3.6 (Exact type-count law).** For every odd prime $f$ and every divisor $d$ of $(f-1)/2$,
$$\#\{u \in (\mathbb{Z}/f)^\times : T_f(u) = d\} = 2\,\varphi(d).$$

*Proof.* Apply Lemma 2.3 (the counting form) along the same two covers with the predicate "type $= d$". The bijection gives $\#\{u : T_f(u) = d\} = \#\{a < 2n : \operatorname{ord}_n(a \bmod n) = d\}$. The two-to-one fold gives $2\cdot\#\{b < n : \operatorname{ord}_n(b) = d\} = 2\varphi(d)$. $\square$

*Examples.* For $f = 13$ ($n = 6$) the census is $\{1:2, 2:2, 3:4, 6:4\}$ and $H(T) = \mathcal{H}(6) \approx 1.9183$. For $f = 37$ ($n = 18$) it is $\{1:2, 2:2, 3:4, 6:4, 9:12, 18:12\}$ and $H(T) = \mathcal{H}(18) \approx 2.2244$. Neither degree is prime, so neither case was available before.

---

## 4. The two-power ladder and the Fermat rungs

**Lemma 4.1 (Two summation identities).** For all $m \ge 0$,
$$\sum_{k=0}^{m-1} 2^k = 2^m - 1, \qquad \sum_{k=0}^{m-1} 2^k (m - k) = 2^{m+1} - m - 2.$$

*Proof.* Induction on $m$. For the second, write $(m+1) - k = (m - k) + 1$ to get $\sum_{k \le m} 2^k(m+1-k) = \sum_{k \le m} 2^k(m-k) + \sum_{k \le m} 2^k$. The $k = m$ term of the first sum vanishes, so this equals $(2^{m+1} - m - 2) + (2^{m+1} - 1) = 2^{m+2} - (m+1) - 2$. $\square$

**Theorem 4.2 (Two-power ladder).** For every $m \ge 0$,
$$\mathcal{H}(2^m) = 2 - \frac{2}{2^m} = 2 - 2^{1-m}.$$
The rungs are $0, 1, \tfrac32, \tfrac74, \tfrac{15}{8}, \tfrac{31}{16}, \dots$, increasing to the ceiling of $2$ bits.

*Proof.* The divisors of $2^m$ are $2^0, 2^1, \dots, 2^m$. The term $d = 1$ of (3.1) contributes $\frac{1}{2^m}\log_2 2^m = \frac{m}{2^m}$. For $d = 2^{k+1}$, $0 \le k < m$, we have $\varphi(d) = 2^k$, contributing
$$\frac{2^k}{2^m}\log_2\frac{2^m}{2^k} = \frac{2^k (m - k)}{2^m}.$$
By Lemma 4.1,
$$\mathcal{H}(2^m) = \frac{m + 2^{m+1} - m - 2}{2^m} = 2 - \frac{2}{2^m}. \qquad\square$$

**Corollary 4.3 (Fermat rungs).** Let $f = 2^{m+1}+1$ be prime: $f \in \{3, 5, 17, 257, 65537\}$ are the known cases. Then $\mathbb{Q}(\zeta_f)^+$ is cyclic of degree $2^m$, and
$$H(T) = 2 - 2^{1-m}.$$

*Proof.* $(f-1)/2 = 2^m$. Apply Theorem 3.5, then Theorem 4.2. $\square$

| $f$ | $(f-1)/2$ | $H(T)$ |
|---|---|---|
| $3$ | $1$ | $0$ |
| $5$ | $2$ | $1$ |
| $17$ | $8$ | $7/4$ |
| $257$ | $128$ | $127/64$ |
| $65537$ | $32768$ | $2 - 2^{-14}$ |

The Fermat primes are exactly the primes $f$ for which the regular $f$-gon is constructible by ruler and compass, i.e. for which $\mathbb{Q}(\zeta_f)^+$ is a $2$-power tower of quadratic extensions. The octic field is the first Fermat rung of composite degree. This is precisely why the prime-degree ladder missed it.

---

## 5. The octic rung $\mathbb{Q}(\zeta_{17})^+$

Fix $f = 17$, so $G_{17} \cong C_8$.

**Proposition 5.1 (Four types).** $|G_{17}| = 8$. For every $u \in (\mathbb{Z}/17)^\times$, $T_{17}(u)$ divides $8$, hence $T_{17}(u) \in \{1, 2, 4, 8\}$.

*Proof.* Lemma 3.3 gives $|G_{17}| = 8$. Element orders divide the group order (Lagrange), and the divisors of $8 = 2^3$ are $1, 2, 4, 8$. $\square$

**Theorem 5.2 (Octic splitting law).** Let $p$ be an integer coprime to $17$. The residue degree of $p$ in $\mathbb{Q}(\zeta_{17})^+$ is
$$T_{17}(p) = \begin{cases} 1 & p \equiv \pm 1, \\ 2 & p \equiv \pm 4, \\ 4 & p \equiv \pm 2,\ \pm 8, \\ 8 & p \equiv \pm 3,\ \pm 5,\ \pm 6,\ \pm 7 \end{cases} \pmod{17}.$$

*Proof sketch.* By Proposition 5.1 and the $\pm1$-criterion, $T_{17}(u)$ is $1$ if $u = \pm1$; else $2$ if $u^2 = \pm 1$; else $4$ if $u^4 = \pm1$; else $8$. Evaluate this for the sixteen classes. For instance, $4^2 = 16 \equiv -1$; $2^2 = 4$ and $2^4 = 16 \equiv -1$; $8^2 \equiv 13 \equiv -4$ and $8^4 \equiv 16$; $3$ is a primitive root, so $3^k \not\equiv \pm 1$ for $k < 8$. $\square$

*Examples.* $103 \equiv 1$ splits completely (degree $1$, eight primes above it). $13 \equiv -4$ has degree $2$. $2$ has degree $4$. $3$ is inert (degree $8$).

**Theorem 5.3 (Type census).** Among the sixteen classes of $(\mathbb{Z}/17)^\times$, exactly $2, 2, 4, 8$ have residue degree $1, 2, 4, 8$ respectively. The type densities are
$$\Pr[T = 1] = \tfrac18,\quad \Pr[T = 2] = \tfrac18,\quad \Pr[T = 4] = \tfrac14,\quad \Pr[T = 8] = \tfrac12,$$
the $C_8$ profile $\varphi(d)/8$.

*Proof.* Theorem 3.6 with $(\varphi(1), \varphi(2), \varphi(4), \varphi(8)) = (1, 1, 2, 4)$. $\square$

The reported percentages $12\%, 12\%, 25\%, 50\%$ are these densities. The two $12\%$ entries are $12.5\%$ truncated.

**Theorem 5.4 (Octic entropy).** $H(T) = 7/4$ bits exactly, and $H(T) = \mathcal{H}(8)$.

*Proof.* Corollary 4.3 with $m = 3$: $2 - 2^{-2} = 7/4$. Directly from the census: $\tfrac18\cdot 3 + \tfrac18 \cdot 3 + \tfrac14 \cdot 2 + \tfrac12 \cdot 1 = \tfrac74$. $\square$

**Theorem 5.5 (Full pinning at degree 8).** Let $\sigma(u) = \{u, -u\}$ be the sign class. Then
$$H(T \mid \sigma) = 0,\qquad I(T;\sigma) = \tfrac74,$$
and likewise for the full residue $u = p \bmod 17$:
$$H(T \mid p \bmod 17) = 0, \qquad I(p \bmod 17;\, T) = H(T) = \tfrac74 .$$

*Proof.* If $\sigma(u) = \sigma(v)$ then $v = \pm u$, so $T_{17}(v) = T_{17}(u)$ by sign invariance. Determination gives $H(T\mid\sigma) = 0$. The residue map is injective, hence also determines $T$. Combine with Theorem 5.4. $\square$

*Remark (what pinning does and does not say).* Full pinning holds because the observable *determines* the type. For abelian fields this is the arithmetic content of the Artin map: splitting is a congruence condition. Pinning is still a genuine property of the observable and not of the field. Section 6 exhibits a natural observable, the Legendre symbol, that is informative without pinning.

**Proposition 5.6 (The reported value).** The experimentally reported $1.7474$ satisfies
$$1.7474 < H(T) = 1.75 \quad\text{and}\quad H(T) - 1.7474 < 0.003 .$$

*Proof.* $1.75 - 1.7474 = 0.0026$. $\square$

The sign of the discrepancy is the expected one. The plug-in estimator, which inserts empirical frequencies into Shannon's formula, is biased downward because entropy is concave. For orientation: the primes up to $10^6$ (excluding $17$) have empirical type frequencies $0.1246, 0.1244, 0.2499, 0.5012$ and plug-in entropy $\approx 1.7478$.

---

## 6. The octic tower

The cyclic group $C_8$ has a unique subgroup of each index $1, 2, 4, 8$, so $\mathbb{Q}(\zeta_{17})^+$ sits atop a unique tower
$$\mathbb{Q} \subset \mathbb{Q}(\sqrt{17}) \subset K_4 \subset \mathbb{Q}(\zeta_{17})^+, \qquad \text{degrees } 1, 2, 4, 8 .$$
The Frobenius of $p$ in the degree-$2^j$ layer is the class of $u = p \bmod 17$ modulo the kernel of $u \mapsto u^{16/2^j}$. So the layer-$j$ observable may be taken to be
$$X_j(u) = u^{16/2^j} \in (\mathbb{Z}/17)^\times :$$
- $X_1 = u^8$, the Legendre symbol $\left(\frac{u}{17}\right)$ by Euler's criterion;
- $X_2 = u^4$, the quartic layer;
- $X_3 = u^2$, which determines the sign class.

**Theorem 6.1 (Conditional entropies along the tower).**
$$H(T \mid u^8) = \tfrac34, \qquad H(T \mid u^4) = \tfrac14, \qquad H(T \mid u^2) = 0 .$$

*Proof.*

*Quadratic layer.* $u^8 \in \{1, 16\}$, each value taken on eight classes. On the squares $\{\pm1, \pm2, \pm4, \pm8\}$ the types are $\{1:2,\ 2:2,\ 4:4\}$, with fibre entropy $3 - \frac{1}{8}(2 + 2 + 8) = \tfrac32$. On the non-squares the type is constantly $8$, with entropy $0$. Hence $H(T\mid u^8) = \tfrac12\cdot\tfrac32 = \tfrac34$.

*Quartic layer.* $u^4 \in \{1, 4, 13, 16\}$, each value on four classes. Only the fibre $u^4 = 1$, namely $u \in \{\pm 1, \pm 4\}$ with types $1, 1, 2, 2$, is non-constant. Its entropy is $1$, so $H(T \mid u^4) = \tfrac14 \cdot 1 = \tfrac14$.

*Octic layer.* In the field $\mathbb{Z}/17$, $u^2 = v^2$ forces $v = \pm u$. So $u^2$ determines the sign class, hence $T$. $\square$

**Theorem 6.2 (Octic tower filtration).**
$$I(T; u^8) = 1 = \mathcal{H}(2),\qquad I(T; u^4) = \tfrac32 = \mathcal{H}(4),\qquad I(T; u^2) = \tfrac74 = \mathcal{H}(8).$$
The degree-$2^j$ layer carries about the octic type exactly the entropy of its *own* splitting type, $2 - 2^{1-j}$. Each step of the tower adds exactly one increment of the two-power ladder, and the top layer achieves full pinning.

*Proof.* Subtract Theorem 6.1 from $H(T) = 7/4$ and compare with Theorem 4.2 at $m = 1, 2, 3$. $\square$

**Corollary 6.3 (The Legendre symbol does not pin).**
$$H(T \mid (\tfrac{p}{17})) = \tfrac34 > 0 \quad\text{and}\quad I(T; (\tfrac{p}{17})) = 1 < \tfrac74 = H(T).$$

So pinning is selective. A perfectly natural, computable observable, quadratic residuosity mod 17, explains only $4/7$ of the octic splitting entropy.

---

## 7. The semiprime channel at the octic rung

### 7.1 The exponent-model channel

For a semiprime $N = pq$ with $p, q \nmid f$, the residue $N \bmod f$ is the product of residues, and in discrete-logarithm coordinates the product becomes a sum. In the abstract cyclic model $C_n$ one therefore takes $(a, b)$ uniform on $(\mathbb{Z}/n)^2$, with
$$S = a + b \bmod n \quad(\text{the class of } N),\qquad \tau = \{\operatorname{ord}_n(a), \operatorname{ord}_n(b)\}\ (\text{unordered type pair}),$$
and $\tau^{\mathrm{ord}} = (\operatorname{ord}_n(a), \operatorname{ord}_n(b))$ for the ordered pair.

**Definition 7.1.** $I_{\mathrm{pair}}(n) = I(S; \tau)$ and $I^{\mathrm{ord}}_{\mathrm{pair}}(n) = I(S; \tau^{\mathrm{ord}})$.

**Theorem 7.2 (Octic semiprime channel).**
1. $I_{\mathrm{pair}}(8) = 21/16$.
2. $I_{\mathrm{pair}}(n) = I^{\mathrm{ord}}_{\mathrm{pair}}(n)$ for every $n$. In particular the which-factor increment at $n = 8$ is exactly $0$.
3. $I_{\mathrm{pair}}(8) > 1$: the channel exceeds the one-bit binary cap.
4. The reported $1.3097$ satisfies $1.3097 < 21/16$ and $21/16 - 1.3097 < 0.003$.

*Proof sketch.*

(1) $S$ is uniform on $\mathbb{Z}/8$, so $H(S) = 3$. The 64 pairs fall into ten unordered type classes. The table below lists each class with its size and the distribution of $S$ on it.

| type pair | size | values of $S$ | $H(S\mid\cdot)$ |
|---|---|---|---|
| $\{1,1\}$ | 1 | $0$ | 0 |
| $\{1,2\}$ | 2 | $4$ | 0 |
| $\{1,4\}$ | 4 | $2,6$ (2 each) | 1 |
| $\{1,8\}$ | 8 | $1,3,5,7$ (2 each) | 2 |
| $\{2,2\}$ | 1 | $0$ | 0 |
| $\{2,4\}$ | 4 | $2,6$ (2 each) | 1 |
| $\{2,8\}$ | 8 | $1,3,5,7$ (2 each) | 2 |
| $\{4,4\}$ | 4 | $0,4$ (2 each) | 1 |
| $\{4,8\}$ | 16 | $1,3,5,7$ (4 each) | 2 |
| $\{8,8\}$ | 16 | $0,2,4,6$ (4 each) | 2 |

Weighting by size,
$$H(S\mid\tau) = \frac{4 + 16 + 4 + 16 + 4 + 32 + 32}{64} = \frac{108}{64} = \frac{27}{16},$$
so $I_{\mathrm{pair}}(8) = 3 - \tfrac{27}{16} = \tfrac{21}{16}$.

(2) The ordered pair is the unordered pair together with an orientation bit, which is only defined when the two types differ. The swap $(a, b) \mapsto (b, a)$ preserves $S$ and exchanges the two orientations inside each unordered class. So within each class, $S$ has the same conditional distribution under both orientations. Refining by orientation therefore does not change $H(S \mid \cdot)$.

(3) and (4) are numerical: $21/16 = 1.3125$ and $1.3125 - 1.3097 = 0.0028$. $\square$

The reported which-factor value $0.0002$ is therefore sampling noise around an exact zero.

---

## 8. Algorithms

The results above give exact, very cheap procedures. We record them in the form used for computation.

**Algorithm A (Real residue degree by the $\pm1$-criterion).** Input: odd prime $f$, residue $u$ with $f \nmid u$. Set $x \leftarrow u \bmod f$, $k \leftarrow 1$. While $x \notin \{1, f-1\}$: set $x \leftarrow xu \bmod f$ and $k \leftarrow k+1$. Output $k$. This takes $O(T_f(u)) \le O(f)$ modular multiplications. An $O(\tau(n)\log f)$ variant tests $u^d \equiv \pm 1$ only for divisors $d$ of $n = (f-1)/2$ and returns the least such $d$.

**Algorithm B (Exact type entropy by the $\varphi$-law).** Input $n$. Factor $n$, enumerate divisors $d$, and output $\sum_{d\mid n}\frac{\varphi(d)}{n}\log_2\frac{n}{\varphi(d)}$. By Theorem 3.5, $\mathcal{H}((f-1)/2)$ is then the exact splitting entropy of $\mathbb{Q}(\zeta_f)^+$, with no enumeration of residues. The cost is dominated by factoring $n$.

**Algorithm C (Conditional entropy of a type given an observable).** Partition $(\mathbb{Z}/f)^\times$ by the observable, compute the fibre entropy of $T_f$ on each block with the fibre formula, and average with block weights. This takes $O(f)$ evaluations. It is used for the tower filtration and the pinning tests.

**Algorithm D (Plug-in estimation from primes).** Sieve the primes up to $X$, compute $T_f(p \bmod f)$, and plug the empirical frequencies into Shannon's formula. This is the experimental estimator. The theory above supplies its exact target.

---

## 9. Discussion

**What is structural, and what is arithmetic.** Theorem 3.5 shows that the splitting entropy of $\mathbb{Q}(\zeta_f)^+$ is a purely group-theoretic invariant of $C_{(f-1)/2}$. The arithmetic enters in exactly two places: the cyclicity of $(\mathbb{Z}/f)^\times$, and the identification of Frobenius with the residue class (and, via Dirichlet, of prime densities with uniform measure on classes). Everything else is the uniform-cover principle. This explains why the experimentally observed "ladder" is universal: it is not a numerical accident of particular conductors.

**The octic rung is not special, but it is diagnostic.** Degree $8$ was the first composite rung reached experimentally, and it confirmed the conjectured value. It is also the first rung where the subfield lattice is a chain of length $3$, which makes the tower filtration visible. The staircase $1, 3/2, 7/4$ is the two-power ladder read inside a single field.

**Pinning versus information.** For every abelian field the residue mod the conductor pins the splitting type, because splitting is a congruence condition. The informative question is which *coarser* observables pin. In the octic field, $u^2$ (equivalently, the sign class) pins, $u^4$ leaves $1/4$ bit, and the Legendre symbol leaves $3/4$ bit.

**Finite-sample bias.** Both reported values, $1.7474$ and $1.3097$, lie slightly below their exact targets $7/4$ and $21/16$, by less than $0.003$ in each case. This is consistent with the systematic downward bias of plug-in entropy estimators.

---

## 10. Future directions

1. **The subfield information law.** *Conjecture:* for every $n$ and every $d \mid n$, $I(\operatorname{ord}_n(a);\, a \bmod d) = \mathcal{H}(d)$ in the exponent model. The Frobenius in the degree-$d$ subfield carries about the top type exactly the entropy of its own type. Since $\operatorname{ord}_d(a) = d/\gcd(a, d)$ is a function both of $\operatorname{ord}_n(a)$ and of $a \bmod d$, the law amounts to conditional independence of $\operatorname{ord}_n(a)$ and $a \bmod d$ given $\operatorname{ord}_d(a)$. This should follow from the transitive action of $(\mathbb{Z}/n)^\times$ on fibres. The octic tower proves the cases $(8,2), (8,4), (8,8)$, and numerical experiments on small $n$ agree.

2. **The $p$-power entropy ceiling.** *Conjecture:* for each prime $p$, $\mathcal{H}(p^m)$ increases strictly in $m$ and converges to $\frac{p}{p-1}\log_2 p - \log_2(p-1)$. This limit is $2$ bits for $p = 2$, matching Theorem 4.2. Among abelian $p$-groups of fixed order, the cyclic one should maximise order-type entropy. The $\varphi$-law reduces $\mathcal{H}(p^m)$ to a weighted geometric sum with a closed form analogous to Lemma 4.1.

3. **The composite-conductor ladder.** *Conjecture:* for every conductor $f \ge 3$, the splitting entropy of $\mathbb{Q}(\zeta_f)^+$ equals the order-type entropy of the finite abelian group $(\mathbb{Z}/f)^\times/\{\pm1\}$, and among abelian groups of order $n$ this is uniquely maximised by $C_n$. Non-cyclic real cyclotomic fields (e.g. $f = 15, 21, 24$) would then carry strictly less type information than cyclic fields of the same degree. Example: $\mathcal{H}(4) = 3/2$, while the order-type entropy of $C_2 \times C_2$ is $2 - \tfrac34\log_2 3 \approx 0.811$. The uniform-cover argument does not use cyclicity beyond parametrising the group, which suggests a direct generalisation.

4. **The two-power semiprime limit.** *Conjecture:* $I_{\mathrm{pair}}(2^m) = \tfrac43(1 - 4^{-m})$ for all $m \ge 1$. This gives $1, 5/4, 21/16, \dots$, increasing to a ceiling of $4/3$ bits. The case $m = 3$ is Theorem 7.2, and numerical values for $m \le 5$ agree.

---

## 11. Conclusion

The octic real cyclotomic field $\mathbb{Q}(\zeta_{17})^+$ has splitting-type entropy exactly $7/4$ bits, fully pinned by the residue of $p$ modulo $17$ and already by its sign class. It sits on the two-power ladder $2 - 2^{1-m}$ at $m = 3$. Its tower of subfields filters the $7/4$ bits as $1 + \tfrac12 + \tfrac14$. Behind these numbers is a single principle, the invariance of counting entropy under uniform covers. It identifies the splitting entropy of $\mathbb{Q}(\zeta_f)^+$ with the order-type entropy of $C_{(f-1)/2}$ for every odd prime $f$, so the ladder extends to every degree.
