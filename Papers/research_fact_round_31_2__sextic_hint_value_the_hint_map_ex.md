# The Hint Extends Beyond Degree Five: Exact Hint Values and a CRT Defect Law for Cyclic Splitting-Type Channels

**Aristotle**

*September 2026*

---

## Abstract

Let $N = pq$ be a product of two primes and let $K$ be a cyclic number field of degree $n$ and prime conductor $f$. The *hint value* of $K$ measures how much more the factor residues $(p \bmod f, q \bmod f)$ reveal about the unordered pair of residue degrees $\{f_K(p), f_K(q)\}$ than the product residue $N \bmod f$ reveals. We compute this quantity exactly for the real sextic field $\mathbb{Q}(\zeta_{13})^+$ (Galois group $C_6$, conductor $13$). A numerical experiment had estimated $+1.6407$ bits. The exact value is

$$\log_2 3 + \tfrac{1}{18} \approx 1.64052 \text{ bits}.$$

The product view carries exactly $\log_2 3 - \tfrac19$ bits and the joint residue view exactly $2\log_2 3 - \tfrac1{18}$ bits. The sum dial and the gap dial each carry the entire hint. For the gap dial this uses the fact that $\mathbb{Q}(\zeta_{13})^+$ is real. As a result the hint synergy lies exactly on the redundancy floor. The field-level value coincides with an abstract *hint map* $h(n)$, defined as the conditional entropy of the unordered pair of orders of two uniform elements of $\mathbb{Z}/n$ given their sum.

Our main theorem is a general **CRT defect law**: for coprime $m, n \ge 1$,

$$h(mn) = h(m) + h(n) + \delta(m)\,\delta(n), \qquad \delta(n) = 1 - \frac{1}{n^2}\sum_{d\mid n}\varphi(d)^2,$$

where $\delta(n)$ is the probability that two uniform elements of $\mathbb{Z}/n$ have different orders. Hence the hint map is strictly superadditive over coprime non-trivial factors. The proof rests on an *unordered-pair entropy law*, $H(\{X, Y\}) = H(X, Y) - \Pr(X \neq Y)$ for i.i.d. $X, Y$. As a by-product we obtain an information-theoretic proof that $n \mapsto \sum_{d\mid n}\varphi(d)^2$ is multiplicative.

---

## 1. Introduction

### 1.1 The information battery

A recurring experimental design asks how much a cheap, public observation of a semiprime reveals about arithmetic features of its hidden factors, compared with an expensive, private observation. In the setting studied here:

* the **hidden label** is the unordered pair of splitting types (residue degrees) of the two prime factors $p, q$ of $N = pq$ in a fixed abelian number field $K$;
* the **product view** is the residue $N \bmod f$, where $f$ is the conductor of $K$;
* the **factor view** is the ordered pair $(p \bmod f, q \bmod f)$, or equivalently the pair of sum and gap residues $(s, d) = (p+q, p-q) \bmod f$ when $f$ is odd.

The *hint value* is the difference between the mutual information of the label with the factor view and its mutual information with the product view. Earlier rounds of the experiment worked in fields of degree at most $5$. Round 31 was the first to reach degree $6$, with the field $\mathbb{Q}(\zeta_{13})^+$, the maximal real subfield of the $13$th cyclotomic field. It reported

| view | reported (bits) |
|---|---|
| product view $N \bmod 13$ | $1.4704$ |
| joint residue view $(s, d)$ | $3.1110$ |
| hint value | $+1.6407$ |

together with the qualitative verdicts "walls clean" and "the hint map extends beyond degree 5."

### 1.2 Summary of results

1. **Exact round-31 values (Theorem 3.2).** The three rows are exactly $\log_2 3 - \tfrac19$, $2\log_2 3 - \tfrac1{18}$ and $\log_2 3 + \tfrac1{18}$. The reported figures are finite-sample estimates: the hint is overshot by more than $10^{-4}$ bits and the joint row undershot by more than $3\cdot 10^{-3}$ bits.
2. **Maximal redundancy (Theorem 3.4).** Together with $N$, each of the dials $s$ and $d$ determines the label. The sum dial does so by Vieta's formulas. The gap dial does so by Vieta's formulas combined with the reality of the field. So the hint synergy equals $-(\log_2 3 + \tfrac1{18})$, which is exactly the lower wall.
3. **Field model equals exponent model (Theorem 3.3).** The field-level hint value equals $h(6)$, where $h$ is the hint map of the abstract cyclic type channel.
4. **Values, order and walls of the hint map (Theorems 4.2–4.4).** Exact values of $h(2), \dots, h(6)$; the strict order $h(2) < h(3) < h(5) < h(4) < h(6)$; non-monotonicity; and the bounds $0 \le h(n) \le \min(H(\text{label}), \log_2 n)$.
5. **The CRT defect law (Theorem 5.6)** and strict superadditivity (Corollary 5.7).
6. **Totient closed form (Theorem 6.1)** for $\delta(n)$, and multiplicativity of $\sum_{d\mid n}\varphi(d)^2$ (Corollary 6.2).

Throughout, "entropy" means Shannon entropy in bits of a function of a uniformly distributed random element of a finite set. All entropies are exact real numbers computed from fibre counts.

---

## 2. Preliminaries

### 2.1 Counting entropy

Let $S$ be a finite non-empty set carrying the uniform distribution, and let $F : S \to A$ be any map. The entropy of $F$ is

$$H(F) = -\sum_{a \in F(S)} \frac{|F^{-1}(a)|}{|S|}\log_2\frac{|F^{-1}(a)|}{|S|}.$$

Joint entropies are $H(F, G) = H((F, G))$. Conditional entropy is $H(F \mid G) = H(F, G) - H(G)$, and mutual information is $I(F; G) = H(F) - H(F \mid G)$. Two facts are used repeatedly:

* if $G$ determines $F$ (that is, $G(x) = G(y) \Rightarrow F(x) = F(y)$), then $H(F \mid G) = 0$ and $I(F; G) = H(F)$;
* if every fibre of $G$ has at most $k$ elements, then $H(F \mid G) \le \log_2 k$.

### 2.2 Splitting types in cyclic fields of prime conductor

Let $f$ be an odd prime and $g$ a primitive root modulo $f$. For a unit $u \in (\mathbb{Z}/f)^\times$ write $\operatorname{ind}(u) \in \mathbb{Z}/(f-1)$ for its discrete logarithm, so that $u = g^{\operatorname{ind}(u)}$. For each divisor $n \mid f - 1$, the field $\mathbb{Q}(\zeta_f)$ has a unique subfield $K_n$ of degree $n$, and $\operatorname{Gal}(K_n/\mathbb{Q}) \cong \mathbb{Z}/n$. A prime $p \ne f$ is unramified in $K_n$. Its Frobenius corresponds to $\operatorname{ind}(p) \bmod n$, and its residue degree is the order of the Frobenius:

$$f_{K_n}(p) = T_n(\operatorname{ind}(p)), \qquad T_n(a) := \operatorname{ord}_{\mathbb{Z}/n}(a) = \frac{n}{\gcd(a, n)}.$$

For $f = 13$ and $n = 6$, $K_6 = \mathbb{Q}(\zeta_{13})^+$. Equivalently, the residue degree of $p$ is the order of $p$ in $(\mathbb{Z}/13)^\times/\{\pm 1\}$. In particular

$$f_{K_6}(u) = f_{K_6}(-u) \qquad (u \in (\mathbb{Z}/13)^\times), \tag{2.1}$$

which expresses the reality of $K_6$.

### 2.3 The cyclic type channel

**Definition 2.1 (cyclic type channel).** For $n \ge 1$ let $B_n = (\mathbb{Z}/n)^2$ with the uniform distribution. For $(a, b) \in B_n$ define

* the *label* $L_n(a, b) = \{T_n(a), T_n(b)\}$, an unordered pair (a multiset of size two);
* the *product residue* $\Pi_n(a, b) = a + b \bmod n$.

When $p \equiv g^a$ and $q \equiv g^b \pmod f$ we have $pq \equiv g^{a+b}$, so the product residue is the exponent of $N$.

**Definition 2.2 (the hint map).**

$$h(n) := I(L_n; \mathrm{id}) - I(L_n; \Pi_n) = H(L_n \mid \Pi_n).$$

The identity view $\mathrm{id}$ determines $L_n$, so $I(L_n;\mathrm{id}) = H(L_n)$ and the two expressions agree.

**Definition 2.3 (auxiliary quantities).**

* the *pair entropy* $P(n) := H(L_n)$;
* the *product information* $J(n) := I(L_n; \Pi_n)$, so that $h(n) = P(n) - J(n)$;
* the *type entropy* $\tau(n) := H(T_n(a))$ for $a$ uniform in $\mathbb{Z}/n$;
* the *distinctness probability* $\delta(n) := \Pr_{(a,b) \in B_n}[T_n(a) \neq T_n(b)]$.

---

## 3. The round-31 battery over $\mathbb{Q}(\zeta_{13})^+$

### 3.1 The population and the views

The population is $\Omega = (\mathbb{Z}/13)^\times \times (\mathbb{Z}/13)^\times$, which has $144$ elements, with the uniform distribution. It models the residues $(p \bmod 13, q \bmod 13)$ of the two factors. The label is

$$\Lambda(u, v) = \{f_{K_6}(u), f_{K_6}(v)\}.$$

The views are $N = uv$, $s = u + v$, $d = u - v$ (all mod $13$), the factor view $(u, v)$, and the joint residue view $(s, d)$. Since $2$ is invertible mod $13$, $(s, d)$ determines $(u, v)$, so the factor view and the joint residue view carry the same information.

The **hint value** is $\mathrm{hint} = I(\Lambda; u, v) - I(\Lambda; N)$. The **sum hint** and **gap hint** are $I(\Lambda; N, s) - I(\Lambda; N)$ and $I(\Lambda; N, d) - I(\Lambda; N)$. The **hint synergy** is $\mathrm{hint} - \mathrm{sumHint} - \mathrm{gapHint}$, the co-information of the two dials conditioned on $N$.

### 3.2 Fibre counts

**Lemma 3.1.** Among the $144$ pairs:

(a) The ten label classes have sizes $4, 8, 16, 16, 4, 16, 16, 16, 16, 32$.

(b) The classes of the pair (label, $N$) consist of $12$ classes of size $2$, $26$ classes of size $4$ and $2$ classes of size $8$.

(c) $N$ takes each of its $12$ values exactly $12$ times.

*Proof sketch.* The exponent $a = \operatorname{ind}(u) \bmod 6$ is uniform on $\mathbb{Z}/6$, and each residue class has exactly $2$ units. The type distribution on $\mathbb{Z}/6$ is: type $1$ with probability $\tfrac16$ ($a = 0$), type $2$ with $\tfrac16$ ($a=3$), type $3$ with $\tfrac13$ ($a = 2, 4$) and type $6$ with $\tfrac13$ ($a = 1, 5$). Multiplying out the unordered pairs gives (a): for instance $\{3,6\}$ occurs with probability $2\cdot\tfrac13\cdot\tfrac13 = \tfrac{32}{144}$. Parts (b) and (c) follow by direct enumeration. $\square$

**Theorem 3.2 (exact round-31 table).**

$$H(\Lambda) = I(\Lambda; s, d) = 2\log_2 3 - \tfrac{1}{18} \approx 3.11437,$$
$$I(\Lambda; N) = \log_2 3 - \tfrac19 \approx 1.47385,$$
$$\mathrm{hint} = \log_2 3 + \tfrac1{18} \approx 1.64052.$$

In particular the reported value $1.6407$ exceeds the exact hint value by more than $10^{-4}$, and the reported joint row $3.1110$ falls below the exact value by more than $3\cdot10^{-3}$.

*Proof.* By Lemma 3.1(b),

$$H(\Lambda, N) = \tfrac{24}{144}\log_2 72 + \tfrac{104}{144}\log_2 36 + \tfrac{16}{144}\log_2 18.$$

Writing $\ell = \log_2 3$ gives $\log_2 72 = 3 + 2\ell$, $\log_2 36 = 2 + 2\ell$ and $\log_2 18 = 1 + 2\ell$. Hence

$$H(\Lambda, N) = \frac{72 + 208 + 16}{144} + 2\ell = \frac{37}{18} + 2\ell.$$

By (c), $H(N) = \log_2 12 = 2 + \ell$. So $H(\Lambda \mid N) = \ell + \tfrac1{18}$. Since the factor view determines $\Lambda$, the hint is $H(\Lambda) - I(\Lambda; N) = H(\Lambda \mid N)$. The value $H(\Lambda)$ follows from (a) in the same way, and $I(\Lambda; N) = H(\Lambda) - H(\Lambda\mid N) = \ell - \tfrac19$. The numerical claims follow from $1.58496 < \log_2 3 < 1.58497$. $\square$

**Theorem 3.3 (field model equals exponent model).**

$$I(\Lambda; N) = J(6), \qquad H(\Lambda) = P(6), \qquad \mathrm{hint} = h(6).$$

*Proof sketch.* The discrete logarithm followed by reduction mod $6$ maps $\Omega$ onto $B_6$, and every fibre has size $4$. The label $\Lambda$ factors through this map as $L_6$, and $N$ corresponds to $\Pi_6$ refined by a coordinate (the exponent mod $2$) that is independent of the label. Uniform fibrations preserve these entropies, and the closed forms agree with those of the abstract channel. $\square$

### 3.3 The two dials

**Lemma 3.4a (Vieta for the sum dial).** In an integral domain $R$, if $pq = p'q'$ and $p + q = p' + q'$, then $(p', q') \in \{(p, q), (q, p)\}$.

*Proof.* $(p' - p)(p' - q) = p'^2 - (p+q)p' + pq = p'^2 - (p'+q')p' + p'q' = 0$. $\square$

**Lemma 3.4b (Vieta for the gap dial).** In an integral domain $R$, if $pq = p'q'$ and $p - q = p' - q'$, then $(p', q') \in \{(p, q), (-q, -p)\}$.

*Proof.* $(p' - p)(p' + q) = p'^2 - (p - q)p' - pq = p'^2 - (p' - q')p' - p'q' = 0$. $\square$

**Theorem 3.4 (maximal redundancy; walls clean).** Over $\mathbb{Q}(\zeta_{13})^+$:

1. $(N, s)$ determines $\Lambda$, and $(N, d)$ determines $\Lambda$;
2. $\mathrm{sumHint} = \mathrm{gapHint} = \mathrm{hint} = \log_2 3 + \tfrac1{18}$;
3. $\mathrm{synergy} = -(\log_2 3 + \tfrac1{18}) = -\min(\mathrm{sumHint}, \mathrm{gapHint})$, so the redundancy wall is attained exactly;
4. $\mathrm{synergy} < 1$ and $0 < \mathrm{hint} < H(\Lambda)$.

*Proof.* (1) For the sum dial, Lemma 3.4a over $\mathbb{F}_{13}$ shows that pairs with the same $(N, s)$ agree up to swapping, and $\Lambda$ is swap-invariant. For the gap dial, Lemma 3.4b shows that pairs with the same $(N, d)$ agree up to $(u, v) \mapsto (-v, -u)$. By (2.1), $\{f(-v), f(-u)\} = \{f(u), f(v)\}$. (2) Hence $I(\Lambda; N, s) = I(\Lambda; N, d) = H(\Lambda)$, and each conditional hint equals $H(\Lambda) - I(\Lambda; N) = \mathrm{hint}$. (3) and (4) are then arithmetic. The general walls are $-\min(\mathrm{sumHint},\mathrm{gapHint}) \le \mathrm{synergy} \le 1$. The upper wall holds because, given $(N, s)$, the pair is determined up to order, so $d$ is determined up to sign and carries at most one further bit. $\square$

**Proposition 3.5 (the sum dial without the product).**

$$I(\Lambda; s) = 2\log_2 3 + \tfrac{29}{36} - \tfrac{11}{12}\log_2 11 \approx 0.80434 .$$

*Proof sketch.* The value $s = 0$ is attained by $12$ pairs, namely $(u, -u)$. Each of the $12$ non-zero values is attained by $11$ pairs, which gives $H(s) = 4 + 2\log_2 3 - \tfrac{132\log_2 11 + 12(2 + \log_2 3)}{144}$. The classes of (label, $s$) consist of eight of size $1$, fifty of size $2$, four of size $3$ and six of size $4$, which gives $H(\Lambda, s) = 4 + 2\log_2 3 - \tfrac{148 + 12\log_2 3}{144}$. Then combine $I = H(\Lambda) + H(s) - H(\Lambda, s)$. $\square$

So the sum dial is informative only in combination with $N$. The $\log_2 11$ term records the one unequal fibre $s = 0$.

---

## 4. The hint map: values, order and walls

**Theorem 4.1.** $h(n) = H(L_n \mid \Pi_n)$ for every $n$.

This is immediate from Definition 2.2.

**Theorem 4.2 (first values).**

$$h(2) = \tfrac12,\quad h(3) = \log_2 3 - \tfrac23,\quad h(4) = \tfrac98,$$
$$h(5) = \log_2 5 - \tfrac{12}{25}\log_2 3 - \tfrac{16}{25},\quad h(6) = \log_2 3 + \tfrac1{18}.$$

*Proof sketch.* Direct fibre counts in $B_n$. For example, for $n = 2$ the fibre $\Pi = 0$ is $\{(0,0),(1,1)\}$, with labels $\{1,1\}$ and $\{2,2\}$ each of probability $\tfrac12$, so it contributes $1$ bit. The fibre $\Pi = 1$ is $\{(0,1),(1,0)\}$, with the single label $\{1,2\}$, so it contributes $0$. Averaging gives $\tfrac12$. $\square$

**Theorem 4.3 (order; the hint extends beyond degree five).**

$$h(2) < h(3) < h(5) < h(4) < h(6).$$

In particular $h(6) > h(n)$ for all $n \in \{2,3,4,5\}$, and $h$ is not monotone, since $h(5) < h(4)$.

*Proof.* Numerically $h(2) = 0.5$, $h(3) \approx 0.91830$, $h(5) \approx 0.92115$, $h(4) = 1.125$ and $h(6) \approx 1.64052$. Rigorous brackets for $\log_2 3$ and $\log_2 5$ certify each inequality. The gap $h(5) - h(3)$ is below $3\cdot 10^{-3}$. $\square$

**Theorem 4.4 (walls).** For every $n \ge 1$:

$$0 \le h(n) \le P(n) \qquad\text{and}\qquad h(n) \le \log_2 n.$$

*Proof.* Conditional entropy is non-negative and bounded by the unconditional entropy. Each fibre $\{(a, b) : a + b \equiv c\}$ has exactly $n$ elements, so the conditional entropy is at most $\log_2 n$. $\square$

---

## 5. The CRT defect law

### 5.1 The unordered-pair entropy law

**Theorem 5.1 (unordered-pair entropy law).** Let $S$ be a finite non-empty set, $\beta$ a linearly ordered set, and $g : S \to \beta$. For $(x, y)$ uniform on $S \times S$,

$$H(\{g(x), g(y)\}) = H(g(x), g(y)) - \Pr[g(x) \neq g(y)].$$

*Proof.* Represent the unordered pair as $(\min, \max)$. For any $(x_0, y_0)$, the fibre of the unordered pair through $(x_0, y_0)$ is the union of the ordered fibre of $(g(x_0), g(y_0))$ and the ordered fibre of $(g(y_0), g(x_0))$. The coordinate swap $(x, y) \mapsto (y, x)$ is a bijection between these two ordered fibres, so they have the same size. If $g(x_0) \neq g(y_0)$ they are disjoint, and the unordered fibre is exactly twice as large. If $g(x_0) = g(y_0)$ they coincide. Hence, pointwise,

$$\log_2 |\text{unordered fibre}| = \log_2 |\text{ordered fibre}| + \mathbf{1}[g(x_0) \neq g(y_0)].$$

Averaging $-\log_2(|\text{fibre}|/|S|^2)$ over $S \times S$ gives the claim. $\square$

Informally: forgetting the order of an i.i.d. pair costs exactly one bit on the off-diagonal and nothing on the diagonal.

**Corollary 5.2 (label entropy).** For $n \ge 1$, $P(n) = 2\tau(n) - \delta(n)$.

*Proof.* Apply Theorem 5.1 with $S = \mathbb{Z}/n$ and $g = T_n$. The ordered pair $(T_n(a), T_n(b))$ has entropy $2\tau(n)$ because $a$ and $b$ are independent. $\square$

### 5.2 CRT structure

Let $m, n$ be coprime and positive. The Chinese Remainder Theorem gives a bijection $\mathbb{Z}/mn \to \mathbb{Z}/m \times \mathbb{Z}/n$, $a \mapsto (a \bmod m, a \bmod n)$. It carries the uniform distribution to the product of uniform distributions, and it carries addition to componentwise addition.

**Lemma 5.3 (orders multiply).** $T_{mn}(a) = T_m(a \bmod m)\cdot T_n(a \bmod n)$. Consequently

$$T_{mn}(a) = T_{mn}(b) \iff T_m(a) = T_m(b) \ \text{ and } \ T_n(a) = T_n(b).$$

*Proof.* The order of $a$ in $\mathbb{Z}/m \times \mathbb{Z}/n$ is the lcm of the component orders. These divide the coprime numbers $m$ and $n$, so the lcm is their product. A product $d_1 d_2$ with $d_1 \mid m$ and $d_2 \mid n$ determines $d_1 = \gcd(d_1 d_2, m)$ and $d_2 = \gcd(d_1 d_2, n)$, which gives the equivalence. $\square$

**Corollary 5.4.** (a) $\tau(mn) = \tau(m) + \tau(n)$. (b) $1 - \delta(mn) = (1 - \delta(m))(1 - \delta(n))$.

*Proof.* (a) By Lemma 5.3, $T_{mn}(a)$ is equivalent to the pair of independent variables $(T_m(a \bmod m), T_n(a \bmod n))$. (b) The equal-type event over $\mathbb{Z}/mn$ is the intersection of the two equal-type events, which are independent under the CRT product structure. So the equal-type counts multiply: $\#\{\text{equal}\}_{mn} = \#\{\text{equal}\}_m \cdot \#\{\text{equal}\}_n$. Divide by $(mn)^2$. $\square$

**Lemma 5.5 (the product information is additive).** $J(mn) = J(m) + J(n)$ for coprime $m, n$.

*Proof sketch.* First, $J(n) = I(L_n; \Pi_n)$ equals the mutual information $I(\vec L_n; \Pi_n)$ between the *ordered* type pair $\vec L_n = (T_n(a), T_n(b))$ and $\Pi_n$. Indeed,

$$I(\vec L_n; \Pi_n) - I(L_n; \Pi_n) = H(\vec L_n \mid L_n) - H(\vec L_n \mid L_n, \Pi_n),$$

and both terms equal $\delta(n)$: given the unordered label, the ordered label is a fair coin on the off-diagonal, and it stays fair after conditioning on $\Pi_n$, because the swap $(a, b) \mapsto (b, a)$ preserves $\Pi_n$ and $L_n$ and flips the order. Second, under the CRT, $\vec L_{mn}$ corresponds bijectively (Lemma 5.3) to $(\vec L_m, \vec L_n)$, and $\Pi_{mn}$ to $(\Pi_m, \Pi_n)$. The two components $(\vec L_m, \Pi_m)$ and $(\vec L_n, \Pi_n)$ are independent. Mutual information is additive over independent product channels. $\square$

### 5.3 The law

**Theorem 5.6 (CRT Defect Law).** For coprime positive integers $m, n$,

$$\boxed{\,h(mn) = h(m) + h(n) + \delta(m)\,\delta(n).\,}$$

*Proof.* By Corollary 5.2, $h(k) = P(k) - J(k) = 2\tau(k) - \delta(k) - J(k)$. By Corollary 5.4(a) and Lemma 5.5, the terms $2\tau$ and $J$ are additive over $(m, n)$. Therefore

$$h(mn) - h(m) - h(n) = \delta(m) + \delta(n) - \delta(mn).$$

By Corollary 5.4(b), $\delta(mn) = 1 - (1-\delta(m))(1-\delta(n)) = \delta(m) + \delta(n) - \delta(m)\delta(n)$. $\square$

**Interpretation.** $\delta(m)\delta(n)$ is the probability that the two exponents are *doubly distinct*, meaning distinct in type both modulo $m$ and modulo $n$. On that event the composite channel's unordered label loses one bit of order information, whereas the two component channels would together lose two bits. The whole superadditivity of the hint map comes from this one-bit saving, which is a feature of the unordered label. The product channel and the type entropies are exactly additive.

**Corollary 5.7 (strict superadditivity).** For coprime $m, n$, $h(mn) \ge h(m) + h(n)$. If moreover $m, n \ge 2$, the inequality is strict.

*Proof.* $\delta \ge 0$ always. For $k \ge 2$, the exponents $0$ and $1$ have types $1$ and $k$, so $\delta(k) \ge 2/k^2 > 0$. $\square$

**Examples.**

| $mn$ | $m, n$ | $\delta(m)$ | $\delta(n)$ | defect | $h(m) + h(n)$ | $h(mn)$ |
|---|---|---|---|---|---|---|
| $6$ | $2, 3$ | $1/2$ | $4/9$ | $2/9$ | $1.41830$ | $1.64052$ |
| $10$ | $2, 5$ | $1/2$ | $8/25$ | $4/25$ | $1.42115$ | $1.58115$ |
| $12$ | $4, 3$ | $5/8$ | $4/9$ | $5/18$ | $2.04330$ | $2.32107$ |
| $15$ | $3, 5$ | $4/9$ | $8/25$ | $32/225$ | $1.83944$ | $1.98166$ |

At degree $6$, $h(6) - h(2) - h(3) = \tfrac29$ exactly.

---

## 6. Arithmetic form of the defect

**Theorem 6.1 (totient closed form).** For $n \ge 1$,

$$\#\{(a, b) \in B_n : T_n(a) = T_n(b)\} = \sum_{d \mid n}\varphi(d)^2, \qquad \delta(n) = 1 - \frac{1}{n^2}\sum_{d\mid n}\varphi(d)^2.$$

*Proof.* For any map $g$, the number of collisions $g(x) = g(y)$ in $S \times S$ equals $\sum_v |g^{-1}(v)|^2$. In $\mathbb{Z}/n$ the number of elements of order exactly $d$ is $\varphi(d)$ for each $d \mid n$. $\square$

**Corollary 6.2 (multiplicativity of $\sum \varphi^2$).** The function $\Sigma(n) = \sum_{d\mid n}\varphi(d)^2$ satisfies $\Sigma(mn) = \Sigma(m)\Sigma(n)$ for coprime $m, n$.

*Proof.* Combine Theorem 6.1 with the multiplicativity of equal-type counts (Corollary 5.4(b)). $\square$

This is usually derived from the fact that the Dirichlet convolution of multiplicative functions is multiplicative. Here it is a consequence of the CRT structure of the splitting-type channel.

**Corollary 6.3 (hint map in totients).** For coprime positive $m, n$,

$$h(mn) = h(m) + h(n) + \left(1 - \frac{\Sigma(m)}{m^2}\right)\left(1 - \frac{\Sigma(n)}{n^2}\right).$$

Sample values: $\Sigma(6) = 1 + 1 + 4 + 4 = 10$, so $\delta(6) = \tfrac{13}{18}$; $\Sigma(12) = 30$, so $\delta(12) = \tfrac{19}{24}$.

---

## 7. Algorithms

**Algorithm A (exact hint map by fibre counting).** For each $c \in \mathbb{Z}/n$, enumerate the $n$ pairs $(a, c - a)$, tally the labels $\{T_n(a), T_n(c-a)\}$, and accumulate $\frac1n H(\text{tally})$. The cost is $O(n^2)$ gcd evaluations after an $O(n\log n)$ precomputation of $T_n$. This gives $h(n)$ exactly as a combination of logarithms of integers.

**Algorithm B (CRT reduction).** Factor $n = \prod_i p_i^{e_i}$. Compute $h(p_i^{e_i})$ by Algorithm A and $\delta(p_i^{e_i})$ by Theorem 6.1. Then fold with Theorem 5.6, maintaining $(h, 1 - \delta)$:

$$(h, \bar\delta) \otimes (h', \bar\delta') = \big(h + h' + (1 - \bar\delta)(1 - \bar\delta'),\ \bar\delta\bar\delta'\big).$$

The cost is dominated by the largest prime-power rung, $O(\max_i p_i^{2e_i})$, instead of $O(n^2)$.

**Algorithm C (field-level battery).** For prime $f$ and $n \mid f-1$, enumerate all $(f-1)^2$ unit pairs, label them by residue degrees through a table of discrete logarithms, and compute the mutual informations of the label with $N$, $(s, d)$, $(N, s)$ and $(N, d)$. For $f = 13$, $n = 6$ this reproduces Theorems 3.2–3.4 exactly.

---

## 8. Discussion

**Where the extra information lives.** One might guess that the superadditivity of $h$ reflects some interaction between the product view and the CRT decomposition. It does not. The product channel $J$ and the type entropy $\tau$ are both exactly additive. The whole defect comes from the order-forgetting correction $-\delta$ in the label entropy. This is structurally the same as the entropy of two indistinguishable particles: symmetrising costs one bit exactly when the particles occupy different states. For a composite system, "different" is the union of two independent component events, which gives the inclusion–exclusion defect $\delta(m)\delta(n)$.

**Exactness versus estimation.** The experimental rows $1.4704$, $3.1110$ and $1.6407$ are close to, but distinct from, the exact values. With exact closed forms, a verdict such as "walls clean" becomes a statement: the redundancy floor is attained with equality, for an identifiable algebraic reason.

**Role of reality.** Theorem 3.4 uses the reality of $\mathbb{Q}(\zeta_{13})^+$ essentially. Numerically, in the imaginary degree-4 subfield of $\mathbb{Q}(\zeta_{13})$ the gap hint is $0.5$ bits against a hint of $1.125$ bits, and in the full field $\mathbb{Q}(\zeta_{13})$ (degree 12) it is $\approx 1.6405$ against $\approx 2.3211$. These values are computational observations and have not been proved.

**Applications.** (i) *Cryptanalytic calibration*: the hint map quantifies exactly how much splitting information about the factors of an RSA-type modulus is hidden beyond public residues, namely at most $\log_2 n$ bits per conductor. (ii) *Information decomposition*: the battery gives a fully solvable test case, with exact redundancy and synergy values, for partial-information-decomposition methods. (iii) *Arithmetic*: Corollary 6.2 is a small example of multiplicativity obtained from entropy.

---

## 9. Future directions

1. **Binary-entropy law for prime rungs.** Conjecture: for every prime $q$,
   $$h(q) = \tfrac{q-1}{q}H_b\!\left(\tfrac2q\right) + \tfrac1q H_b\!\left(\tfrac1q\right),$$
   so $h(q) \to 0$. Only the types $1$ and $q$ occur. In the fibre $\Pi = c \ne 0$, only the pairs $(0, c)$ and $(c, 0)$ contain a type-$1$ exponent, so the label is a biased coin with bias $2/q$. In the fibre $c = 0$ it has bias $1/q$. Numerically the formula agrees to twelve digits for $q \le 19$. Together with Theorem 5.6, this would reduce $h$ to its values on proper prime powers.
2. **Field–exponent transfer at every prime conductor.** Conjecture: for every prime $f$ and $n \mid f-1$, the battery over the degree-$n$ subfield of $\mathbb{Q}(\zeta_f)$ has hint value exactly $h(n)$. The discrete logarithm is a uniform fibration of the unit pairs over $B_n$, and $N \bmod f$ refines $\Pi_n$ only through a label-independent coordinate. Computations for $f \in \{7, 11, 13, 17\}$ agree. The case $f = 13$, $n = 6$ is Theorem 3.3.
3. **Reality criterion.** Conjecture: $\mathrm{gapHint} = \mathrm{hint}$ if and only if the labels are invariant under $u \mapsto -u$, that is, for subfields of $\mathbb{Q}(\zeta_f)$, if and only if the field is real. In the non-real case the synergy then lies strictly above the redundancy floor.
4. **Prime powers.** Find closed forms for $h(p^e)$ to complete the hint map through the defect law. Numerically, $h(2) = \tfrac12$, $h(4) = \tfrac98$, $h(8) = \tfrac{49}{32}$, $h(16) = \tfrac{225}{128}$, and more generally the computed values for $k \le 6$ fit $h(2^k) = 2(1 - 2^{-k})^2$, which would give $h(2^k) \to 2$. This pattern is an unproved observation.

---

## 10. Conclusion

The degree-six hint value of round 31 is exactly $\log_2 3 + \tfrac1{18}$ bits. The single sum and gap dials are perfectly redundant, for reasons given by Vieta's formulas and the reality of the field. The field-level battery agrees exactly with the abstract cyclic type channel. Across all coprime composite degrees, the hint map obeys the CRT defect law $h(mn) = h(m) + h(n) + \delta(m)\delta(n)$. The defect is the probability of double distinctness, given explicitly by Euler's totient. In short, the hint map extends beyond degree five, and on coprime composites it is superadditive in a precisely quantified way.
