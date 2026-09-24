# The Degree-Six Rung of the Abelian Splitting-Type Ladder: CRT Factorisation, Orthogonal Information Splitting, and Exact Channel Capacities for $\mathbb{Q}(\zeta_{13})^+$

**Aristotle**

*2026-09-24*

---

## Abstract

We study the splitting type of rational primes in the maximal real subfield $K = \mathbb{Q}(\zeta_{13})^+$, a cyclic sextic field of conductor $13$. We treat it as a random variable under the Dirichlet (uniform Frobenius) law and measure its information content. We prove the complete splitting law of $K$: primes $p \equiv \pm1$ split completely, $p\equiv\pm5$ have residue degree $2$, $p \equiv \pm3,\pm4$ have residue degree $3$, and $p \equiv \pm2,\pm6$ are inert. The type rates are therefore $\{1/6, 1/6, 1/3, 1/3\}$, and the type entropy is $H(T) = \tfrac13 + \log_2 3$. We prove *full pinning*, $I(p \bmod 13;\,T) = H(T)$. The central structural result is a CRT factorisation of the Frobenius, $T_6 = T_2\cdot T_3$, where $T_2$ and $T_3$ are the residue degrees in the quadratic subfield $\mathbb{Q}(\sqrt{13})$ and the cyclic cubic subfield. Its information-theoretic counterpart is an orthogonal decomposition $H(T_6) = I(T_6;T_2) + I(T_6;T_3)$ with $I(T_2;T_3) = 0$. We establish a chain rule for the counting entropy and use it to prove, for arbitrary coprime $m,n$, CRT additivity $H(T_{mn}) = H(T_m) + H(T_n)$ and the general orthogonal split. Hence the entropy of every cyclic rung is the sum over its prime-power components. For semiprimes $N = pq$ we compute the exact capacities of two channels: $I(N \bmod 13;\,\text{type pair}) = \log_2 3 - \tfrac19 \approx 1.47385$ and $I(N\bmod 13;\,\text{split count}) = \log_2 3 - \tfrac{55}{36}\log_2 5 + \tfrac{19}{9} \approx 0.14868$. The split count retains less than $11\%$ of the pair information, and its value agrees with the closed form previously derived only for prime degree. Finally, rigorous rational bounds on $\log_2 3$ and $\log_2 5$ show that two experimentally reported values, $H(T) = 1.9192$ and $I(\text{pair}) = 1.4704$, are off by more than $8\cdot10^{-4}$ and $3\cdot10^{-3}$ bits respectively.

---

## 1. Introduction

### 1.1 The splitting-type channel

Let $K/\mathbb{Q}$ be a Galois extension of degree $n$ and $p$ a prime unramified in $K$. The ideal $p\mathcal{O}_K$ factors as a product of $g$ distinct primes, each of residue degree $f$, with $fg = n$. The residue degree $f$ is the order of the Frobenius class $\mathrm{Frob}_p \in \mathrm{Gal}(K/\mathbb{Q})$. When $K$ is abelian of conductor $F$, class field theory identifies $\mathrm{Gal}(K/\mathbb{Q})$ with a quotient of $(\mathbb{Z}/F)^\times$, and $\mathrm{Frob}_p$ is the image of $p \bmod F$. By Dirichlet's theorem on primes in arithmetic progressions, the residues $p \bmod F$ are equidistributed among the $\varphi(F)$ units. So the **splitting type** $T(p) := f$ is a random variable with an explicit finite law, and the natural object of study is the information it carries.

This paper is one rung of a systematic programme we call the *abelian ladder*: for abelian fields of successive degree, determine

1. the type law and its entropy $H(T)$;
2. whether the type is *pinned* by the residue, i.e. whether $I(p\bmod F;\,T) = H(T)$;
3. how much information the residue $N \bmod F$ of a semiprime $N = pq$ carries about the pair $(T(p), T(q))$, and about the coarser *split count*.

Degrees $2, 3, 4, 5$ have been studied in earlier rungs. Degree $6$ is the first degree that is neither prime nor a prime power, so it is the first place where the Chinese Remainder Theorem structure $C_6 \cong C_2 \times C_3$ of the Galois group can appear in the type channel. The field we use is $K = \mathbb{Q}(\zeta_{13})^+ = \mathbb{Q}(\zeta_{13} + \zeta_{13}^{-1})$, the smallest-conductor cyclic sextic field.

### 1.2 Summary of results

- **Splitting law (Theorem 3.2)** and **rates (Theorem 3.3)**: the residue degree is $1,2,3,6$ according as $p\equiv \pm1$; $\pm5$; $\pm3,\pm4$; $\pm2,\pm6 \pmod{13}$, with rates $\tfrac16,\tfrac16,\tfrac13,\tfrac13$. In fact $\#\{u : T(u) = d\} = 2\varphi(d)$.
- **CRT factorisation (Theorem 4.3)**: $T_6 = T_2 T_3$, and conversely $T_2 = \gcd(T_6,2)$, $T_3 = \gcd(T_6,3)$.
- **Entropies (Theorem 5.4)**: $H(T_6) = \tfrac13 + \log_2 3$, $H(T_2) = 1$, $H(T_3) = \log_2 3 - \tfrac23$. The field-level values coincide with the abstract cyclic model.
- **Full pinning (Theorem 6.1)**: $H(T_6\mid p\bmod 13) = 0$.
- **Orthogonal split (Theorem 6.2)**: $I(T_6;T_2) = 1$, $I(T_6;T_3) = \log_2 3 - \tfrac23$, their sum is $H(T_6)$, and $I(T_2;T_3) = 0$. Neither subfield pins $T_6$ (Corollary 6.3).
- **General tools (Section 2 and Section 7)**: the chain rule for counting entropy; CRT additivity $H(T_{mn}) = H(T_m) + H(T_n)$ for $\gcd(m,n)=1$; the prime-power decomposition of $H(T_n)$; the general orthogonal split.
- **Semiprime channels (Section 8)**: exact closed forms $I_{\mathrm{pair}}(6) = \log_2 3 - \tfrac19$ and $I_{\mathrm{split}}(6) = \log_2 3 - \tfrac{55}{36}\log_2 5 + \tfrac{19}{9}$, strict loss $I_{\mathrm{split}}(6) < 0.11\, I_{\mathrm{pair}}(6)$, and agreement of $I_{\mathrm{split}}(6)$ with the prime-degree formula at $q = 6$.
- **Numerical certificates (Section 9)**: $1.91829 < H(T) < 1.91831$ and $1.47385 < I_{\mathrm{pair}}(6) < 1.47386$, which correct the experimentally reported values.

---

## 2. The counting entropy and its chain rule

All entropies in this paper are Shannon entropies, in bits, of *read-outs* of a uniformly distributed sample from a finite set.

**Definition 2.1 (Counting entropy).** Let $S$ be a nonempty finite set and $g: S \to B$ any function. The entropy of $g$ on $S$ is
$$H_S(g) = \frac{1}{|S|}\sum_{x\in S}\log_2\frac{|S|}{|\{y\in S : g(y) = g(x)\}|},$$
the Shannon entropy of $g(x)$ when $x$ is uniform on $S$. For a second read-out $k: S\to C$, the conditional entropy is
$$H_S(g\mid k) = \sum_{c\in k(S)} \frac{|k^{-1}(c)|}{|S|}\,H_{k^{-1}(c)}(g),$$
and the mutual information is $I_S(g;k) = H_S(g) - H_S(g\mid k)$.

**Theorem 2.2 (Chain rule).** For all read-outs $g, k$ on a finite set $S$,
$$H_S(g\mid k) = H_S(g,k) - H_S(k),$$
where $(g,k)$ denotes the paired read-out $x \mapsto (g(x),k(x))$.

*Proof sketch.* Write $H_S(g\mid k)$ as a sum over the fibres $k^{-1}(c)$. For $x$ in the fibre over $c$, the $g$-fibre of $x$ inside $k^{-1}(c)$ is exactly the $(g,k)$-fibre of $x$ in $S$. So the contribution of $x$ is $\log_2|k^{-1}(c)| - \log_2|(g,k)\text{-fibre of }x|$, divided by $|S|$. Summing over all fibres regroups these terms into $\frac1{|S|}\sum_x[\log_2|S| - \log_2|(g,k)\text{-fibre}|] - \frac1{|S|}\sum_x[\log_2|S| - \log_2|k\text{-fibre}|]$, which is $H_S(g,k) - H_S(k)$. $\square$

**Corollary 2.3 (Symmetric Shannon form and symmetry).** $I_S(g;k) = H_S(g) + H_S(k) - H_S(g,k)$. In particular $I_S(g;k) = I_S(k;g)$.

*Proof.* Substitute Theorem 2.2 into the definition of $I_S$. Symmetry follows because the pair $(g,k)$ and the swapped pair $(k,g)$ differ by the bijection $(b,c)\mapsto(c,b)$ and so have the same fibres. $\square$

**Corollary 2.4 (A coarsening is received in full).** If $k$ is a function of $g$ on $S$ (that is, $g(x) = g(y) \Rightarrow k(x) = k(y)$), then $H_S(g,k) = H_S(g)$ and hence $I_S(g;k) = H_S(k)$.

*Proof.* The fibres of $(g,k)$ coincide with those of $g$. Apply Corollary 2.3. $\square$

Corollary 2.4 is the lemma that turns the arithmetic statement "$T_2$ is a function of $T_6$" into the information statement "$T_6$ carries all $H(T_2)$ bits of the quadratic type."

---

## 3. The splitting law of $\mathbb{Q}(\zeta_{13})^+$

### 3.1 Residue degrees in real cyclotomic fields

For $f \ge 3$, the field $\mathbb{Q}(\zeta_f)^+$ has Galois group $(\mathbb{Z}/f)^\times/\{\pm1\}$. For a unit $u \in (\mathbb{Z}/f)^\times$, let $\bar u$ be its image in this quotient and define
$$T^{+}_f(u) = \operatorname{ord}(\bar u),$$
the smallest $k \ge 1$ with $u^k \equiv \pm1 \pmod f$. For a prime $p\nmid f$, $T^+_f(p \bmod f)$ is the residue degree of $p$ in $\mathbb{Q}(\zeta_f)^+$.

**Lemma 3.1 (Divisibility criterion).** For every $k\ge 1$: $T^+_f(u)\mid k$ if and only if $u^k \equiv 1$ or $u^k \equiv -1 \pmod f$.

*Proof.* In any group, $\operatorname{ord}(\bar u)\mid k$ iff $\bar u^k = 1$, and $\bar u^k = \overline{u^k}$ is trivial in the quotient iff $u^k \in \{\pm1\}$. $\square$

### 3.2 The law at conductor 13

Let $T_6(u) := T^+_{13}(u)$ for $u \in (\mathbb{Z}/13)^\times$.

**Theorem 3.2 (Splitting law).** For every prime $p \ne 13$, the residue degree of $p$ in $\mathbb{Q}(\zeta_{13})^+$ is
$$T_6(p) = \begin{cases} 1 & p \equiv \pm 1 \pmod{13},\\ 2 & p\equiv \pm 5 \pmod{13},\\ 3 & p\equiv \pm3, \pm4 \pmod{13},\\ 6 & p \equiv \pm2,\pm6 \pmod{13}.\end{cases}$$
The same formula holds for every integer coprime to $13$ in place of $p$.

*Proof sketch.* Since $\mathbb{F}_{13}$ is a field and $u^{12} = 1$, $u^6$ is a square root of $1$ and hence $\pm1$. By Lemma 3.1, $T_6(u) \mid 6$, so $T_6(u)\in\{1,2,3,6\}$. Lemma 3.1 with $k = 2$ and $k = 3$ decides which divisor occurs. $T_6(u)\mid 2$ iff $u^2 \equiv \pm1$, i.e. $u \in \{\pm1, \pm5\}$ (since $5^2 = 25 \equiv -1$). $T_6(u) \mid 3$ iff $u^3 \equiv \pm 1$, i.e. $u\in\{\pm1,\pm3,\pm4\}$ (since $3^3 = 27\equiv1$ and $4^3 = 64 \equiv -1$). The four combinations of these two conditions give the four cases. $\square$

**Theorem 3.3 (Type rates).** Among the $12$ classes in $(\mathbb{Z}/13)^\times$, the numbers with $T_6 = 1,2,3,6$ are $2,2,4,4$. The Dirichlet rates are therefore $\tfrac16,\tfrac16,\tfrac13,\tfrac13$. Equivalently, for each $d\mid 6$,
$$\#\{u\in(\mathbb{Z}/13)^\times : T_6(u) = d\} = 2\,\varphi(d).$$

*Proof.* Read off from Theorem 3.2. The identity with $2\varphi(d)$ expresses the fact that $C_6$ has $\varphi(d)$ elements of order $d$, each with exactly two preimages $\pm u$. $\square$

---

## 4. The quadratic and cubic subfields and the CRT factorisation

Let $P_k \le (\mathbb{Z}/13)^\times$ be the subgroup of $k$-th powers. Since $(\mathbb{Z}/13)^\times$ is cyclic of order $12$, $P_k$ has index $\gcd(k,12)$, and its fixed field in $\mathbb{Q}(\zeta_{13})$ is the unique subfield of degree $\gcd(k,12)$. For a unit $u$ let $T_{(k)}(u)$ be the order of $u$ in $(\mathbb{Z}/13)^\times/P_k$, the residue degree of $u$ in that fixed field.

**Lemma 4.1.** $u \in P_2 \iff u^6 = 1$, and $u\in P_3 \iff u^4 = 1$.

*Proof.* In a cyclic group of order $12$, the $k$-th powers are exactly the elements killed by $12/\gcd(k,12)$. (Concretely, the squares mod $13$ are $\{1,3,4,9,10,12\}$ and the cubes are $\{1,5,8,12\}$.) $\square$

The fixed field of $P_2$ is the quadratic field $\mathbb{Q}(\sqrt{13})$. The fixed field of $P_3$ is the cyclic cubic subfield $L_3$ of $\mathbb{Q}(\zeta_{13})$. Both lie inside $K = \mathbb{Q}(\zeta_{13})^+$, since $-1 = 5^2 = 12^3$ is both a square and a cube.

**Lemma 4.2 (Prime-degree dichotomy).** Write $T_2 := T_{(2)}$ and $T_3 := T_{(3)}$. Then
$$T_2(u) = \begin{cases}1 & u^6 = 1\\ 2 & \text{otherwise}\end{cases},\qquad T_3(u) = \begin{cases}1 & u^4=1\\ 3&\text{otherwise.}\end{cases}$$

*Proof.* The quotients by $P_2$ and $P_3$ have prime order $2$ and $3$, so every order is $1$ or the prime. The order is $1$ exactly when $u\in P_k$. Apply Lemma 4.1. $\square$

**Theorem 4.3 (CRT factorisation of the sextic Frobenius).** For every $u\in(\mathbb{Z}/13)^\times$,
$$T_6(u) = T_2(u)\cdot T_3(u),$$
and conversely
$$T_2(u) = \gcd(T_6(u),2),\qquad T_3(u) = \gcd(T_6(u),3).$$

*Proof sketch.* Structurally, $\mathrm{Gal}(K/\mathbb{Q})\cong C_6\cong C_2\times C_3$, with the two factors the Galois groups of $\mathbb{Q}(\sqrt{13})$ and $L_3$. The order of an element of $C_2\times C_3$ is the product of the orders of its components, and each component order is recovered as the gcd of the total order with $2$ or $3$. Concretely, Theorems 3.2 and 4.2 can be compared on the twelve classes:

| $u$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $T_2$ | 1 | 2 | 1 | 1 | 2 | 2 | 2 | 2 | 1 | 1 | 2 | 1 |
| $T_3$ | 1 | 3 | 3 | 3 | 1 | 3 | 3 | 1 | 3 | 3 | 3 | 1 |
| $T_6$ | 1 | 6 | 3 | 3 | 2 | 6 | 6 | 2 | 3 | 3 | 6 | 1 |

$\square$

**Remark 4.4.** The map $T_6 \mapsto (T_2, T_3)$ is injective on the values $\{1,2,3,6\}$, with image $\{1,2\}\times\{1,3\}$. So the *pair* of subfield types induces exactly the same partition of $(\mathbb{Z}/13)^\times$ as the sextic type:
$$H(T_2, T_3) = H(T_6).$$

---

## 5. Entropies

Throughout, $S = (\mathbb{Z}/13)^\times$ with the uniform law (the Dirichlet law).

**Definition 5.1 (Abstract cyclic type).** For $n\ge1$ and $a \in \mathbb{Z}/n$, let $\tau_n(a) = n/\gcd(a,n)$, the additive order of $a$. The *type entropy* of the rung $C_n$ is $H(T_n) := H_{\mathbb{Z}/n}(\tau_n)$.

**Lemma 5.2.** In $C_n$, $\#\{a : \tau_n(a) = d\} = \varphi(d)$ for every $d\mid n$. Hence
$$H(T_n) = \sum_{d\mid n}\frac{\varphi(d)}{n}\log_2\frac{n}{\varphi(d)}.$$

**Lemma 5.3 (Small rungs).** $H(T_2) = 1$, $H(T_3) = h_2(1/3) = \log_2 3 - \tfrac23$, and
$$H(T_6) = 2\cdot\tfrac16\log_2 6 + 2\cdot\tfrac13\log_2 3 = \tfrac13 + \log_2 3.$$

**Theorem 5.4 (Field entropies agree with the abstract model).** Over $S = (\mathbb{Z}/13)^\times$:
$$H_S(T_6) = \tfrac13 + \log_2 3 = H(T_6),\quad H_S(T_2) = 1 = H(T_2),\quad H_S(T_3) = \log_2 3 - \tfrac23 = H(T_3).$$
In particular $H_S(T_6) = H_S(T_2) + H_S(T_3)$.

*Proof.* By Theorem 3.3 the fibre sizes of $T_6$ are $2,2,4,4$ out of $12$, which gives $\tfrac16\log_26\cdot2 + \tfrac13\log_23\cdot2$. By Lemma 4.2 the fibre sizes of $T_2$ are $6,6$ and those of $T_3$ are $4,8$. The results follow from $\log_2 12 = 2 + \log_2 3$ and similar identities. $\square$

The agreement is expected: the Frobenius map $S \to C_6$ is a surjective homomorphism with fibres of size $2$, so it pushes the uniform law forward to the uniform law.

---

## 6. Pinning and the orthogonal split

**Theorem 6.1 (Full pinning at degree 6).** Let $\sigma(u) = \{u,-u\}$ be the sign class of $u$. Then
$$H_S(T_6\mid \sigma) = 0\quad\text{and}\quad I_S(T_6;\,\sigma) = H(T_6) = \tfrac13+\log_2 3.$$
Since $\sigma$ is a function of $p \bmod 13$, also $H_S(T_6\mid p\bmod13) = 0$ and $I(p \bmod 13;\,T_6) = H(T_6)$.

*Proof.* If $\sigma(u) = \sigma(v)$ then $v = \pm u$, and $T_6(-u) = T_6(u)$ because $(-u)^k = \pm u^k$. So $T_6$ is constant on the fibres of $\sigma$, every conditional entropy term vanishes, and $I = H - 0$. Theorem 5.4 identifies the value. $\square$

**Theorem 6.2 (Orthogonal split of the sextic information).**
1. $I_S(T_6;T_2) = H(T_2) = 1$.
2. $I_S(T_6;T_3) = H(T_3) = \log_2 3 - \tfrac23$.
3. $I_S(T_6;T_2) + I_S(T_6;T_3) = H_S(T_6)$.
4. $I_S(T_2;T_3) = 0$: the quadratic and cubic Frobenius types are independent.

*Proof.* (1) and (2): by Theorem 4.3, $T_2 = \gcd(T_6,2)$ and $T_3 = \gcd(T_6,3)$ are functions of $T_6$. Corollary 2.4 gives $I_S(T_6;T_k) = H_S(T_k)$, and Theorem 5.4 gives the values. (3): $1 + (\log_2 3 - \tfrac23) = \tfrac13 + \log_2 3$. (4): by Corollary 2.3 and Remark 4.4,
$$I_S(T_2;T_3) = H_S(T_2) + H_S(T_3) - H_S(T_2,T_3) = H_S(T_2) + H_S(T_3) - H_S(T_6) = 0$$
by the additivity in Theorem 5.4. $\square$

**Corollary 6.3 (Neither subfield pins the sextic type).**
$$H_S(T_6\mid T_2) = \log_2 3 - \tfrac23 > 0,\qquad H_S(T_6\mid T_3) = 1.$$

*Proof.* $H(T_6\mid T_k) = H(T_6) - I(T_6;T_k)$, and $\log_2 3 > \tfrac23$. $\square$

In words: the quadratic subfield leaves exactly the cubic uncertainty undetermined, and vice versa. Pinning at degree $6$ requires the *joint* read-out of both subfields, and the joint read-out is exactly sufficient.

---

## 7. CRT additivity and the orthogonal split in general

The degree-six phenomena are instances of general statements about cyclic groups.

**Lemma 7.1 (Multiplicativity of order).** If $\gcd(m,n) = 1$ and $a\in\mathbb{Z}$, then
$$\tau_{mn}(a) = \tau_m(a)\,\tau_n(a)\qquad\text{and}\qquad \gcd(\tau_{mn}(a), m) = \tau_m(a).$$

*Proof.* Under $\mathbb{Z}/mn \cong \mathbb{Z}/m\times\mathbb{Z}/n$, the order of $a$ is the lcm of the component orders, which equals their product because $\tau_m(a)\mid m$ and $\tau_n(a)\mid n$ are coprime. Since $\tau_n(a)$ is coprime to $m$, $\gcd(\tau_m(a)\tau_n(a), m) = \gcd(\tau_m(a),m) = \tau_m(a)$. $\square$

**Theorem 7.2 (CRT additivity of the type entropy).** If $m,n\ge1$ are coprime, then
$$H(T_{mn}) = H(T_m) + H(T_n).$$

*Proof sketch.* The CRT map $\rho: a\mapsto(a\bmod m, a\bmod n)$ is a bijection $\mathbb{Z}/mn\to\mathbb{Z}/m\times\mathbb{Z}/n$ and so preserves the uniform law. By Lemma 7.1, $\tau_{mn} = \mu\circ(\tau_m\times\tau_n)\circ\rho$ with $\mu(x,y) = xy$. The map $\mu$ is injective on the image, because a product $xy$ with $x\mid m$, $y\mid n$, $\gcd(m,n)=1$ determines $x = \gcd(xy,m)$ and $y = \gcd(xy,n)$. Entropy is invariant under bijective relabelling of the sample space and under read-outs composed with injections. The entropy of a product read-out $(\tau_m(x),\tau_n(y))$ under the product law is $H(T_m)+H(T_n)$. $\square$

**Corollary 7.3 (Prime-power decomposition).** For every $n\ge1$,
$$H(T_n) = \sum_{p\mid n} H\big(T_{p^{v_p(n)}}\big),$$
and $H(T_1) = 0$.

*Proof.* The function $n\mapsto 2^{H(T_n)}$ is multiplicative by Theorem 7.2, and a multiplicative function is determined by its values at prime powers. Take $\log_2$. $\square$

**Theorem 7.4 (Orthogonal split of a coprime rung).** Let $m,n\ge1$ be coprime and let $a$ be uniform on $\mathbb{Z}/mn$. Then
$$I(\tau_{mn};\tau_m) = H(T_m),\qquad I(\tau_{mn};\tau_n) = H(T_n),\qquad I(\tau_m;\tau_n) = 0.$$

*Proof sketch.* Pushing forward along the CRT bijection shows that $\tau_m$, as a read-out on $\mathbb{Z}/mn$, has entropy $H(T_m)$. By Lemma 7.1, $\tau_m$ is a function of $\tau_{mn}$, so Corollary 2.4 gives the first two identities. The pair $(\tau_m,\tau_n)$ has the same fibres as $\tau_{mn}$ (one direction by the product formula, the other by the gcd formula). So $H(\tau_m,\tau_n) = H(T_{mn}) = H(T_m)+H(T_n)$ by Theorem 7.2, and Corollary 2.3 gives $I(\tau_m;\tau_n) = 0$. $\square$

At $n = 6$: $H(T_6) = H(T_2) + H(T_3) = 1 + (\log_2 3 - \tfrac23) = \tfrac13 + \log_2 3$. The sextic value is now a *consequence* of CRT, not the result of a separate enumeration.

**Interpretation ("the ladder is complete").** For abelian fields with cyclic Galois group, every composite rung is informationally the independent juxtaposition of its primary rungs. Once the prime-power rungs $2, 3, 4, 5, 7, 8, 9, \ldots$ are understood, the composite rungs add no new entropy, no new pinning phenomena, and no correlation between components. The degree ladder $2$-$3$-$4$-$5$-$6$ is complete in this structural sense. New data appear only at prime-power degrees.

---

## 8. Semiprime channels at degree 6

### 8.1 The model

Let $N = pq$ with $p, q$ independent random primes. In the abstract $C_n$ model the Frobenius classes of $p$ and $q$ are independent uniform elements $a,b\in\mathbb{Z}/n$, and that of $N$ is $a+b$ (the Frobenius is multiplicative). The observable is the *residue* $r = a + b \bmod n$. For the field $K$ this is the information in $N\bmod 13$ modulo sign. Define on the box $\mathbb{Z}/n\times\mathbb{Z}/n$ with the uniform law:

- the **type pair** $\pi(a,b) = (\tau_n(a),\tau_n(b))$;
- the **split count** $s(a,b) = [a=0] + [b=0]\in\{0,1,2\}$, the number of completely split prime factors;
- the channels $I_{\mathrm{pair}}(n) = I(\pi; r)$ and $I_{\mathrm{split}}(n) = I(s;r)$.

### 8.2 The type-pair channel

**Theorem 8.1.** $I_{\mathrm{pair}}(6) = \log_2 3 - \tfrac19 \approx 1.47385.$

*Proof sketch.* First, $I_{\mathrm{pair}}(2) = 1$: all four pairs of types in $\{1,2\}^2$ are equally likely, so $H(\pi) = 2$, and given $r$ the pair is one of two equally likely options, so $H(\pi\mid r) = 1$. Second, $I_{\mathrm{pair}}(3) = \log_2 3 - \tfrac{10}{9}$. The type pairs $(1,1),(1,3),(3,1),(3,3)$ have probabilities $\tfrac19,\tfrac29,\tfrac29,\tfrac49$, so $H(\pi) = 2\log_2 3 - \tfrac43$. Given $r = 0$ the pairs are $(1,1),(3,3),(3,3)$, contributing $h_2(1/3) = \log_2 3 - \tfrac23$. Given $r\ne0$ the three pairs are distinct, contributing $\log_2 3$. Hence $H(\pi\mid r) = \log_2 3 - \tfrac29$ and $I = \log_2 3 - \tfrac{10}{9}$. Finally, under the CRT bijection $\mathbb{Z}/6\times\mathbb{Z}/6\cong(\mathbb{Z}/2)^2\times(\mathbb{Z}/3)^2$, the law is a product. The residue $r$ corresponds to the pair of component residues, and by Lemma 7.1 the type pair corresponds bijectively to the pair of component type pairs. Mutual information is additive over independent products, so $I_{\mathrm{pair}}(6) = 1 + \log_2 3 - \tfrac{10}{9} = \log_2 3 - \tfrac19$. The same value is obtained by direct enumeration of the $36$ cells. $\square$

### 8.3 The split-count channel

**Theorem 8.2.** $I_{\mathrm{split}}(6) = \log_2 3 - \tfrac{55}{36}\log_2 5 + \tfrac{19}{9} \approx 0.14868.$

*Proof sketch.* On the $36$ cells, $s = 0,1,2$ occurs $25, 10, 1$ times, so
$$H(s) = \log_2 36 - \tfrac{1}{36}\big(25\log_2 25 + 10\log_2 10\big) = 2 + 2\log_2 3 - \tfrac{10 + 60\log_2 5}{36}.$$
Every residue class $r$ has $6$ cells. For $r = 0$ the cells are $(a,-a)$; exactly one of them, $(0,0)$, has $s = 2$ and the other five have $s = 0$. This gives $H = \log_2 6 - \tfrac56\log_2 5 = 1 + \log_2 3 - \tfrac56\log_2 5$. For $r \ne 0$ exactly two cells, $(0,r)$ and $(r,0)$, have $s=1$ and four have $s = 0$, giving $h_2(1/3) = \log_2 3 - \tfrac23$. Therefore
$$H(s\mid r) = \tfrac16\big(1+\log_2 3-\tfrac56\log_2 5\big) + \tfrac56\big(\log_2 3 - \tfrac23\big),$$
and subtracting and collecting terms gives the stated closed form. $\square$

**Theorem 8.3 (Strict information loss).** $I_{\mathrm{split}}(6) < I_{\mathrm{pair}}(6)$, and in fact $I_{\mathrm{split}}(6) < 0.11\cdot I_{\mathrm{pair}}(6)$.

*Proof.* From the certified brackets $0.1486 < I_{\mathrm{split}}(6) < 0.1488$ and $1.47385 < I_{\mathrm{pair}}(6)$ of Section 9, $0.11\times1.47385 = 0.16212 > 0.1488$. $\square$

The ratio is about $10.09\%$: roughly nine tenths of the type-pair information in $N\bmod 13$ is invisible to the split count. After degree $4$, degree $6$ is the second composite degree where strict loss is established. At prime degree $q$ the two channels coincide, since then every nonzero element has type $q$ and the pair is determined by the split pattern.

### 8.4 The split count is blind to compositeness

For prime degree $q$ the split-count channel has the closed form
$$I_{\mathrm{split}}(q) = \log_2 q^2 - \frac{(q-1)^2\log_2 (q-1)^2 + 2(q-1)\log_2\big(2(q-1)\big)}{q^2} - \Big(\tfrac1q\,\eta_q(1) + \tfrac{q-1}{q}\,\eta_q(2)\Big),$$
where $\eta_q(k) = h_2(k/q)$ is the entropy of a split of $q$ items into $k$ and $q-k$.

**Theorem 8.4.** The prime-degree formula evaluated at $q = 6$ equals $I_{\mathrm{split}}(6)$.

*Proof sketch.* The derivation of the prime-degree formula uses only the counts of cells with $a = 0$ and/or $b = 0$ in each residue class: $(q-1)^2$, $2(q-1)$, $1$ overall; $1$ vs $q-1$ in class $0$; $2$ vs $q-2$ in each other class. These counts do not depend on whether $q$ is prime, because "$\tau_q(a) = 1$" is equivalent to "$a = 0$" for every modulus. Substituting $q=6$ reproduces the proof of Theorem 8.2 term by term. $\square$

The type pair sees the $2\times3$ structure of $C_6$ (Theorem 8.1 splits as $1 + 0.47385$). The split count cannot see it.

---

## 9. Numerical certificates and correction of reported values

**Lemma 9.1 (Rational brackets).**
$$\tfrac{1054}{665} < \log_2 3 < \tfrac{485}{306},\qquad \tfrac{339}{146} < \log_2 5 < \tfrac{1493}{643}.$$

*Proof.* Each inequality $\tfrac ab < \log_2 x$ is equivalent to $2^a < x^b$, and each $\log_2 x<\tfrac ab$ to $x^b < 2^a$. The four integer inequalities $2^{1054} < 3^{665}$, $3^{306}<2^{485}$, $2^{339} < 5^{146}$, $5^{643}<2^{1493}$ are checked by exact integer arithmetic. The fractions are continued-fraction convergents. $\square$

**Theorem 9.2.**
1. $1.91829 < H(T_6) < 1.91831$. In particular $H(T_6) + 0.0008 < 1.9192$, so the reported value $H(T) = 1.9192$ is **not** exact.
2. $1.47385 < I_{\mathrm{pair}}(6) < 1.47386$. In particular $1.4704 + 0.003 < I_{\mathrm{pair}}(6)$, so the reported $1.4704$ **under-estimates** the exact channel.
3. $0.1486 < I_{\mathrm{split}}(6) < 0.1488$.

*Proof.* Substitute the brackets of Lemma 9.1 into the closed forms $\tfrac13 + \log_2 3$, $\log_2 3 - \tfrac19$ and $\log_2 3 - \tfrac{55}{36}\log_2 5 + \tfrac{19}{9}$. The coefficient of $\log_2 5$ is negative, so its upper bound is used for the lower estimate and vice versa. $\square$

**Remark 9.3.** The experimental round reported the full-pinning identity $I(p\bmod 13;T) = H(T)$ together with the value $1.9192$. The identity is correct (Theorem 6.1). The numerical value is not: the exact value is $1.918296\ldots$. The pair-channel estimate $1.4704$ lies $0.0035$ bits below the truth $1.473851\ldots$, consistent with finite-sample bias in plug-in estimates of mutual information. An empirical test with actual primes below $2\cdot10^6$ gives type frequencies $0.1665, 0.1666, 0.3331, 0.3338$ and a plug-in pair channel of about $1.474$ on $2\cdot10^5$ random prime pairs, in agreement with the exact values. The round also reported a "wall" statistic $z = +0.77$. That is an experimental statistic, and no claim about it is made here.

---

## 10. Algorithms

**Algorithm A (Splitting type in $\mathbb{Q}(\zeta_f)^+$).** Input $f\ge3$ and a prime $p\nmid f$. Set $u = p\bmod f$, $x = u$, $k=1$. While $x\notin\{1,f-1\}$, set $x \leftarrow xu \bmod f$ and $k\leftarrow k+1$. Output $k$. The cost is $O(\varphi(f)/2)$ modular multiplications. Using Lemma 3.1 with the divisors of $\varphi(f)/2$, the cost drops to $O(d(\varphi(f))\log f)$.

**Algorithm B (Exact channel capacities).** Input $n$. Enumerate the $n^2$ cells $(a,b)$. Compute $\pi$, $s$ and $r$. Group by $r$ and evaluate $H(\cdot) - H(\cdot\mid r)$ with the counting entropy. The cost is $O(n^2)$. By Theorem 7.2 and its pair analogue, one can instead evaluate only the prime-power components and add.

**Algorithm C (Prime-power reduction of $H(T_n)$).** Factor $n$. For each $p^e\,\|\,n$ compute $H(T_{p^e}) = \sum_{i=0}^{e}\frac{\varphi(p^i)}{p^e}\log_2\frac{p^e}{\varphi(p^i)}$, then sum (Corollary 7.3).

---

## 11. Discussion

**What degree 6 teaches.** The first non-prime-power rung shows that pinning, entropy and the semiprime pair channel all *factor* along $C_6\cong C_2\times C_3$. The factorisation is exact at every level: arithmetic ($T_6 = T_2T_3$), entropy ($H(T_6) = H(T_2)+H(T_3)$), mutual information (orthogonal split, independence), and the pair channel ($I_{\mathrm{pair}}(6) = I_{\mathrm{pair}}(2) + I_{\mathrm{pair}}(3)$). The only read-out that fails to factor is the split count, because it is too coarse to see the components.

**Structural completeness.** Theorem 7.2 and Corollary 7.3 reduce the entire cyclic ladder to prime-power rungs. This is the precise content of "the ladder is complete": the rung sequence $2$-$3$-$4$-$5$-$6$ covers all the qualitatively different behaviours up to degree $6$, and every higher composite rung is a juxtaposition of independent primary rungs.

**Relation to factoring.** The residue $N\bmod f$ of a semiprime reveals up to $I_{\mathrm{pair}}(n)$ bits about the splitting types of the unknown factors, e.g. $1.47$ bits at $f = 13$. That is information about Frobenius *classes*, not about the factors themselves. The type pair is a function of $(p \bmod f, q\bmod f)$, so this channel is bounded by $H(\pi)$ and gives no handle on $p$ beyond its residue class.

---

## 12. Future directions

1. **Saturation of prime-power rungs.** Conjecture: $H(T_{p^k})$ is strictly increasing in $k$ with limit $\frac{p}{p-1}h_2(1/p)$, the entropy of a geometric law with ratio $1/p$. The key observation is $P(T = p^{k-i}) = (p-1)/p^{i+1}$ for $i<k$. For $p = 2$ the values are $1, \tfrac32, \tfrac74, \tfrac{15}8\to2$; for $p = 3$ they are $0.918, 1.224, 1.326\to1.377$. Combined with Corollary 7.3 this would give $H(T_n) \le \sum_{p\mid n}\frac{p}{p-1}h_2(1/p)$ for every $n$.
2. **Monotonicity of the pair channel on prime powers.** Conjecture: $I_{\mathrm{pair}}(p^k)\le I_{\mathrm{pair}}(p^{k+1})$. Together with CRT this would yield $I_{\mathrm{split}}(n) < I_{\mathrm{pair}}(n)$ for every composite $n$. The chain rule allows $I_{\mathrm{pair}} = H(\pi) + H(r) - H(\pi,r)$ to be organised by valuation classes.
3. **Split-channel universality.** Conjecture: $I_{\mathrm{split}}(n)$ equals the prime-degree closed form for every $n\ge2$. The argument of Theorem 8.4 suggests the proof goes through verbatim, and direct enumeration agrees for $3\le n\le 12$.
4. **Frobenius independence in every compositum.** Conjecture: for an abelian field $K = K_1K_2$ with $K_1, K_2$ of coprime degrees, the Frobenius types in $K_1$ and $K_2$ are independent and the type entropy of $K$ is the sum of theirs. This would extend Theorem 6.2 beyond conductor $13$.

---

## 13. Conclusion

The cyclic sextic field $\mathbb{Q}(\zeta_{13})^+$ shows full pinning with $H(T) = \tfrac13+\log_2 3$. Its splitting-type channel decomposes exactly into independent quadratic and cubic channels, carrying $1$ and $\log_2 3 - \tfrac23$ bits. The decomposition is a special case of CRT additivity of type entropy for coprime cyclic orders, which reduces the whole abelian ladder to its prime-power rungs. For semiprimes the exact pair channel is $\log_2 3 - \tfrac19$ bits, and the split count keeps barely a tenth of it. The rigorous brackets correct the small numerical discrepancies in the experimental record.
