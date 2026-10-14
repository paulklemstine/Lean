# Large Quotients, Small Leaks: The Detector Law for Splitting-Type Channels and the Case of $\mathrm{AGL}(1,8)$

**Aristotle**

*October 2026*

---

## Abstract

For a finite group $G$ with derived subgroup $G' = [G,G]$, consider a uniformly random element $g \in G$ and two readouts of it: its coset $gG'$ in the abelianization $G^{ab} = G/G'$, and a class function $T(g)$ such as a cycle type. When $G$ is a Galois group, these model respectively a congruence residue of a prime $p$ and the factorization pattern (splitting type) of a fixed polynomial modulo $p$; the mutual information $I(\mathrm{coset};T)$ measures how much the splitting type reveals about the residue. It is bounded above by the *cap* $\log_2|G^{ab}|$. Previously examined groups all had $|G^{ab}| \le 4$, and it was already known that the channel is not monotone in $|G|$. We compute the first case with a larger abelianization: the affine group $\mathrm{AGL}(1,8) = \mathbb{F}_8 \rtimes \mathbb{F}_8^\times$ of order $56$, with $G^{ab} \cong C_7$ and cap $\log_2 7 \approx 2.807$ bits. Exactly, the prime channel is $I_1 = \log_2 7 - \tfrac67\log_2 6 = h(1/7) \approx 0.5917$ bits ($21.1\%$ of the cap), and the semiprime channel — the information that an unordered pair of splitting types carries about the coset of the product — is $I_2 = \log_2 7 - \tfrac{78}{49}\log_2 6 + \tfrac{30}{49}\log_2 5 \approx 0.1141$ bits ($4.1\%$ of the cap), the smallest of every group examined. We explain this reversal by a general theorem, the **Detector Law**: if a single value of $T$ occurs exactly on $G \setminus G'$, then $I(\mathrm{coset};T) = h(1/n)$ with $n = |G^{ab}|$, independently of how $T$ behaves on $G'$. Consequently, among such "detector" channels a strictly larger abelianization yields a strictly smaller channel, the channel is at most $(\log_2 n + 3)/n$, and the fraction of the cap realised tends to $0$. The law recovers $\mathrm{AGL}(1,8)$, $A_4 = \mathrm{AGL}(1,4)$ and $V_4$ as instances, and forces $\mathrm{AGL}(1,8)$ to leak less than $A_4$ without numerical evaluation. We formulate a pair-detector formula for the semiprime channel, confirmed by exact enumeration at $n = 3, 4, 7, 31$, and a totient formula for all affine groups $\mathrm{AGL}(1,q)$, verified at $q = 5, 7, 8$ and numerically for all prime powers $q \le 32$. None of this threatens integer factorization: the leakage is $O(1)$ bits about a quantity determined by $N$ itself.

---

## 1. Introduction

### 1.1 Splitting types and residues

Let $f \in \mathbb{Z}[x]$ be a separable polynomial of degree $d$ with splitting field $K$ and Galois group $G = \mathrm{Gal}(K/\mathbb{Q})$, viewed as a group of permutations of the $d$ roots. For a prime $p$ not dividing the discriminant, the Frobenius element $\mathrm{Frob}_p$ is well defined up to conjugacy, and the factorization of $f \bmod p$ into irreducibles has degrees given by the **cycle type** of $\mathrm{Frob}_p$. This is the *splitting type* of $p$.

The maximal abelian subextension $K^{ab} = K^{G'}$ has Galois group $G^{ab} = G/G'$, and by class field theory the image of $\mathrm{Frob}_p$ in $G^{ab}$ depends only on a congruence class of $p$ — it is a *residue* of $p$. Because $G^{ab}$ is abelian, this residue map extends multiplicatively: for a semiprime $N = pq$ the residue class of $N$ corresponds to the product of the images of $\mathrm{Frob}_p$ and $\mathrm{Frob}_q$.

By the Chebotarev density theorem the Frobenius elements are equidistributed in $G$. This motivates the following idealised information-theoretic question:

> *If a uniformly random $g \in G$ is drawn, how many bits does the cycle type $T(g)$ reveal about the coset $gG'$? And if two independent uniform elements $x, y$ are drawn, how many bits does the unordered pair $\{T(x),T(y)\}$ reveal about the coset of $xy$?*

The first quantity, the **prime channel**, measures how much the splitting type of a prime reveals about its residue. The second, the **semiprime channel**, measures how much the splitting types of the two (secret) prime factors of $N$ reveal about the residue of $N$.

### 1.2 The question of monotonicity

Both channels are bounded by the entropy of a uniform coset, $\log_2 |G^{ab}|$, which we call the **cap**. A natural first guess is that richer groups leak more. Exact computations on the small Galois groups of quartics already refuted monotonicity in $|G|$: the dihedral group $D_4$ (order $8$) has prime channel $\approx 1.656$ bits and semiprime channel $\approx 1.430$ bits, while the symmetric group $S_4$ (order $24$) has exactly $1$ bit for both. The natural repair is to blame the cap: $|D_4^{ab}| = 4$ while $|S_4^{ab}| = 2$.

All groups previously examined, however, had $|G^{ab}| \le 4$, so caps at most $2$ bits. The region above two bits was untested. This paper fills that gap with the first example, $\mathrm{AGL}(1,8)$, and finds that it **reverses** the repaired guess as strongly as possible: the largest abelianization yields the smallest channel. We then prove a general theorem explaining why.

### 1.3 Summary of results

1. **(Structure of $\mathrm{AGL}(1,8)$.)** As a permutation group of the eight points of $\mathbb{F}_8$, $\mathrm{AGL}(1,8)$ has order $56$; its derived subgroup is exactly the translation group $C_2^3$; its abelianization is $C_7$ via the multiplier; and its elements have just three cycle types, in proportion $1 : 7 : 48$.
2. **(Exact channels.)** $I_1 = \log_2 7 - \tfrac67\log_2 6 = h(1/7)$ and $I_2 = \log_2 7 - \tfrac{78}{49}\log_2 6 + \tfrac{30}{49}\log_2 5$, with the ordered readout giving the same $I_2$.
3. **(Detector Law.)** For any finite group and any readout that takes one fixed value exactly off $G'$: $I(\mathrm{coset};T) = h(1/|G^{ab}|)$.
4. **(Consequences.)** Strict anti-monotonicity in $|G^{ab}|$, the rate bound $h(1/n) \le (\log_2 n + 3)/n$, vanishing of the channel and of the realised fraction of the cap.
5. **(Extended reversal.)** $\mathrm{AGL}(1,8)$ has the strictly largest cap and the strictly smallest prime channel and cap fraction among $S_3, S_4, A_4, D_4, V_4, C_4$, and is beaten at the semiprime level by $A_4$ (by a factor $> 4$) and by $D_5$ (by a factor $> 8$).
6. **(Conjectures.)** A pair-detector formula for semiprime channels and a totient formula for all $\mathrm{AGL}(1,q)$, with exact and numerical evidence.

---

## 2. The finite channel calculus

Throughout, all logarithms are base $2$ and information is measured in bits.

**Definition 2.1 (Readouts, entropy, mutual information).** Let $S$ be a finite nonempty set equipped with the uniform probability measure. A *readout* is any function $c : S \to K$ into a set $K$. Its law is $P_c(a) = |c^{-1}(a)|/|S|$ and its **entropy** is
$$H(c) = -\sum_{a \in c(S)} P_c(a)\log_2 P_c(a).$$
For two readouts $c, T$, the **joint readout** is $(c,T) : s \mapsto (c(s),T(s))$, the **conditional entropy** is $H(c \mid T) = H(c,T) - H(T)$, and the **mutual information** is
$$I(c;T) = H(c) + H(T) - H(c,T) = H(c) - H(c \mid T).$$

We use the standard facts $0 \le I(c;T) \le H(c)$, and that $H(c) = \log_2 n$ whenever $c$ is *balanced*, i.e. takes $n$ values each on a fibre of the same size.

**Definition 2.2 (Coset readout, cap).** Let $G$ be a finite group with derived subgroup $G'$. A *coset readout* is a map $c: G \to K$ whose fibres are exactly the cosets of $G'$; equivalently $c(g) = c(h) \iff g^{-1}h \in G'$. The canonical example is the quotient map $G \to G^{ab}$. The **cap** of $G$ is $H(c) = \log_2 |G^{ab}|$.

**Lemma 2.3 (Cap by Lagrange).** For any coset readout, $H(c) = \log_2 [G:G']$.

*Proof.* All cosets have $|G'|$ elements (Lagrange), so $c$ is balanced with $[G:G']$ values. $\square$

**Definition 2.4 (Type readout).** A *type readout* is a class function $T$ on $G$, i.e. $T(hgh^{-1}) = T(g)$ for all $g, h$. When $G$ acts on a finite set, the cycle type of $g$ is a type readout; in the Galois setting it is the splitting type.

**Definition 2.5 (Prime and semiprime channels).** The **prime channel** is
$$I_1(G) = I(c;T) \quad\text{on } S = G.$$
The **semiprime channel** is
$$I_2(G) = I\big(c(xy);\ \{T(x),T(y)\}\big) \quad\text{on } S = G \times G,$$
where $\{T(x),T(y)\}$ denotes the unordered pair (multiset of size two). The **ordered semiprime channel** uses $(T(x),T(y))$ instead.

**Proposition 2.6 (Loss identity).** For any coset readout $c$ and any readout $T$,
$$I(c;T) = \log_2|G^{ab}| - H(c \mid T).$$

*Proof.* Combine Definition 2.1 with Lemma 2.3. $\square$

The **deficit** (or *loss*) $H(c \mid T)$ is the uncertainty about the coset that survives observing $T$. The whole paper can be read as a study of how this deficit behaves.

**Remark 2.7 (Consistency).** Since the coset of $xy$ is uniform on $G^{ab}$ when $x,y$ are independent and uniform, and since $\{T(x), T(y)\}$ is a function of $(x,y)$ that discards information, one expects $0 \le I_2 \le I_1 \le \log_2|G^{ab}|$. We verify this chain directly for every group considered.

---

## 3. The group $\mathrm{AGL}(1,8)$

### 3.1 Construction

Let $\mathbb{F}_8 = \mathbb{F}_2[x]/(x^3+x+1)$. We encode an element $a_0 + a_1x + a_2x^2$ by the integer $a_0 + 2a_1 + 4a_2 \in \{0,\dots,7\}$; addition is bitwise exclusive-or, and multiplication is carry-less multiplication reduced modulo $x^3+x+1$. The element $x$ is primitive: $x^3 = x+1$, and its powers
$$x^0, x^1, \dots, x^6 = 1, x, x^2, x+1, x^2+x, x^2+x+1, x^2+1$$
exhaust $\mathbb{F}_8^\times$. Write $\log_x : \mathbb{F}_8^\times \to \mathbb{Z}/7$ for the discrete logarithm.

**Definition 3.1.** For $e \in \mathbb{Z}/7$ and $b \in \mathbb{F}_8$, let $\alpha_{e,b}$ be the permutation $t \mapsto x^e t + b$ of $\mathbb{F}_8$. The **affine group** is $\mathrm{AGL}(1,8) = \{\alpha_{e,b}\} \subset \mathrm{Sym}(\mathbb{F}_8)$.

**Proposition 3.2 (Group law).** $\alpha_{e,b}\circ\alpha_{e',b'} = \alpha_{e+e',\ x^e b' + b}$, $\alpha_{0,0} = \mathrm{id}$, and $\alpha_{e,b}^{-1} = \alpha_{-e,\ x^{-e}b}$ (signs in characteristic $2$ are immaterial). The parametrisation $(e,b)\mapsto\alpha_{e,b}$ is injective, so $\mathrm{AGL}(1,8)$ is a subgroup of $\mathrm{Sym}(\mathbb{F}_8)$ of order $7 \cdot 8 = 56$.

*Proof.* Direct computation pointwise: $x^e(x^{e'}t + b') + b = x^{e+e'}t + (x^e b' + b)$. Injectivity: evaluating at $t=0$ recovers $b$, and at $t=1$ recovers $x^e + b$. $\square$

### 3.2 Derived subgroup and abelianization

**Proposition 3.3 (Derived subgroup).** The derived subgroup of $\mathrm{AGL}(1,8)$ is exactly the translation group $N = \{\alpha_{0,b} : b \in \mathbb{F}_8\} \cong C_2^3$.

*Proof sketch.* By Proposition 3.2 the map $\alpha_{e,b}\mapsto e$ is a homomorphism onto the abelian group $\mathbb{Z}/7$ with kernel $N$, so $G' \subseteq N$. Conversely, the commutator of $\alpha_{1,0}$ (multiplication by $x$) and $\alpha_{0,c}$ (translation by $c$) is the translation by $(x+1)c$; since $x+1 \ne 0$, every translation arises as a commutator. Hence $N \subseteq G'$. $\square$

**Corollary 3.4 (Abelianization).** $G^{ab} \cong C_7$, and the map
$$c(\sigma) = \log_x\big(\sigma(1) + \sigma(0)\big)$$
(which for $\sigma = \alpha_{e,b}$ equals $e$) is a coset readout. The cap is $\log_2 7 \approx 2.807$ bits.

In the Galois picture, this is a residue of $p$ modulo $7$ attached to the cyclic degree-$7$ subextension.

### 3.3 The type readout

**Proposition 3.5 (Cycle types).** The cycle type on the eight points of $\mathbb{F}_8$ is a class function on all of $\mathrm{Sym}(\mathbb{F}_8)$, and on $\mathrm{AGL}(1,8)$ it takes exactly three values:

| element | count | cycle type | coset $e$ |
|---|---|---|---|
| $\alpha_{0,0} = \mathrm{id}$ | $1$ | $[1^8]$ | $0$ |
| $\alpha_{0,b}$, $b\neq 0$ | $7$ | $[2^4]$ | $0$ |
| $\alpha_{e,b}$, $e \neq 0$ | $48$ | $[1,7]$ | $e$ ($8$ elements for each $e\ne0$) |

*Proof.* Conjugation in a symmetric group preserves cycle type. A nonzero translation is a fixed-point-free involution (characteristic $2$), hence $[2^4]$. If $a = x^e \ne 1$, the map $t\mapsto at+b$ has the unique fixed point $t_0 = b/(1+a)$, and conjugating by the translation $t\mapsto t + t_0$ turns it into $t\mapsto at$, which permutes $\mathbb{F}_8^\times$ as multiplication by an element of order $7$ (every nontrivial element of $C_7$ has order $7$). So the remaining seven points form a single $7$-cycle. $\square$

The decisive feature is visible in the table: **all six nontrivial cosets carry the same type $[1,7]$.**

### 3.4 The prime channel

**Theorem 3.6 (Prime channel of $\mathrm{AGL}(1,8)$).**
$$I_1 = \log_2 7 - \tfrac{6}{7}\log_2 6 = h\!\left(\tfrac17\right) \approx 0.59167 \text{ bits},$$
where $h(p) = -p\log_2 p - (1-p)\log_2(1-p)$. Numerically $0.59166 < I_1 < 0.59168$, and $I_1$ realises between $21.07\%$ and $21.08\%$ of the cap. The deficit is $H(c\mid T) = \tfrac67\log_2 6$.

*Proof.* From Proposition 3.5, the type law is $(1,7,48)/56$ and the joint law of (coset, type) consists of the cells $(0,[1^8])$ with mass $1$, $(0,[2^4])$ with mass $7$, and $(e,[1,7])$ with mass $8$ for each of the six $e\ne0$. Hence
$$H(T) = \tfrac{1}{56}\log_2 56 + \tfrac{7}{56}\log_2 8 + \tfrac{48}{56}\log_2\tfrac{56}{48},\qquad H(c,T) = \tfrac{1}{56}\log_2 56 + \tfrac{7}{56}\log_2 8 + \tfrac{48}{56}\log_2 7,$$
and $I_1 = \log_2 7 + H(T) - H(c,T) = \log_2 7 - \tfrac67\log_2 6$. Expanding $h(1/7) = \tfrac17\log_2 7 + \tfrac67\log_2\tfrac76$ gives the same value. The bracket follows from rational bounds on $\log_2 3$ and $\log_2 7$ (obtained from inequalities between integer powers, e.g. $2^{1054} < 3^{665}$). $\square$

**Remark 3.7 (A totient formula at $q = 8$).** For affine groups $\mathrm{AGL}(1,q)$ it had been conjectured, and checked for $q = 5, 7$, that the deficit equals
$$\mathcal{L}(q) = \sum_{\substack{d \mid q-1\\ d>1}} \frac{\varphi(d)}{q-1}\log_2\varphi(d).$$
At $q=8$ the only divisor $d>1$ of $7$ is $7$ itself, with $\varphi(7) = 6$, giving $\mathcal{L}(8) = \tfrac67\log_2 6$ — exactly the deficit of Theorem 3.6. So the formula holds on the genuine permutation group at the first even-characteristic case.

**Remark 3.8 (Ladder collapse).** For $\mathrm{AGL}(1,7)$ (abelianization $C_6$, cap $\log_2 6$) the prime channel is $\tfrac13 + \log_2 3 \approx 1.918$ bits. Passing to $\mathrm{AGL}(1,8)$ the cap grows ($\log_2 7 > \log_2 6$) while the channel drops by more than a factor of three. The cause is arithmetic: $6$ has divisors $1,2,3,6$, so multipliers of different orders produce different cycle types and the type resolves the coset partially; $7$ is prime, so all nontrivial multipliers look alike.

### 3.5 The semiprime channel

**Theorem 3.9 (Semiprime channel of $\mathrm{AGL}(1,8)$).** Over all $56^2 = 3136$ ordered pairs $(x,y)$,
$$I_2 = I\big(c(xy);\{T(x),T(y)\}\big) = \log_2 7 - \tfrac{78}{49}\log_2 6 + \tfrac{30}{49}\log_2 5 \approx 0.11410 \text{ bits}.$$
Numerically $0.11409 < I_2 < 0.11412$, i.e. between $4.06\%$ and $4.07\%$ of the cap. The ordered readout $(T(x),T(y))$ gives exactly the same value. Moreover $0 < I_2 < I_1 < \log_2 7$ and $5I_2 < I_1$.

*Proof sketch.* Write $\varepsilon = [1^8]$, $\tau = [2^4]$, $\rho = [1,7]$. Since $c(xy) = c(x) + c(y)$ in $\mathbb{Z}/7$ and $c(x), c(y)$ are independent and uniform, $c(xy)$ is uniform: $H = \log_2 7$ (each residue has $448$ pairs). The unordered type pair has six values with counts
$$\{\varepsilon,\varepsilon\}:1,\quad \{\varepsilon,\tau\}:14,\quad \{\tau,\tau\}:49,\quad \{\varepsilon,\rho\}:96,\quad \{\tau,\rho\}:672,\quad \{\rho,\rho\}:2304.$$
The joint law has $22$ cells:

| type pair | coset $0$ | each coset $k\ne0$ |
|---|---|---|
| $\{\varepsilon,\varepsilon\}$ | 1 | 0 |
| $\{\varepsilon,\tau\}$ | 14 | 0 |
| $\{\tau,\tau\}$ | 49 | 0 |
| $\{\varepsilon,\rho\}$ | 0 | 16 |
| $\{\tau,\rho\}$ | 0 | 112 |
| $\{\rho,\rho\}$ | 384 | 320 |

The conditional entropy can be read off directly. If neither factor has type $\rho$ (probability $64/3136$) the product coset is $0$. If exactly one does (probability $768/3136 = 12/49$) the product coset is uniform on the six nonzero residues: $\log_2 6$ bits remain. If both do (probability $2304/3136 = 36/49$) the product coset is the sum of two independent uniform nonzero residues of $\mathbb{Z}/7$, which is $0$ with probability $1/6$ and each nonzero value with probability $5/36$; its entropy is $H_7 = \tfrac16\log_2 6 + \tfrac56\log_2\tfrac{36}{5}$. Therefore
$$H(c\mid T) = \tfrac{12}{49}\log_2 6 + \tfrac{36}{49}\Big(\tfrac16\log_2 6 + \tfrac56(2\log_2 6 - \log_2 5)\Big) = \tfrac{78}{49}\log_2 6 - \tfrac{30}{49}\log_2 5,$$
and $I_2 = \log_2 7 - H(c \mid T)$. For the ordered readout the nine type pairs have counts $1:7:7:49:48:48:336:336:2304$ and the joint law has $35$ cells; the same three-case analysis applies verbatim, because *which* factor carries $\rho$ is irrelevant to the distribution of the product coset. $\square$

---

## 4. The Detector Law

### 4.1 Statement

**Definition 4.1 (Trivial-coset detector).** Let $G$ be finite, $c$ a coset readout, and $T$ any readout on $G$. We say $T$ is a **trivial-coset detector** if there is a value $\tau_0$ with
$$T(g) = \tau_0 \iff g \notin G' \qquad (g\in G).$$
That is, every element outside the derived subgroup has the same type, and that type never occurs inside $G'$. No condition is imposed on the values of $T$ on $G'$.

**Definition 4.2 (Detector value).** For an integer $n \ge 2$ put
$$\delta(n) = \log_2 n - \frac{n-1}{n}\log_2(n-1).$$

**Lemma 4.3.** $\delta(n) = h(1/n)$ for every $n\ge2$.

*Proof.* $h(1/n) = \tfrac1n\log_2 n + \tfrac{n-1}{n}\log_2\tfrac{n}{n-1} = \log_2 n - \tfrac{n-1}{n}\log_2(n-1)$. $\square$

**Theorem 4.4 (Detector Law, abstract form).** Let $S$ be a finite set and $c: S\to K$ a balanced readout with $n\ge 2$ values, each fibre of size $k>0$. Fix a value $c_1$ of $c$ and let $T: S \to \mathcal{T}$ be a readout such that, for some $\tau_0$,
$$T(s) = \tau_0 \iff c(s) \ne c_1 \qquad (s\in S).$$
Then $I(c;T) = \delta(n)$, whatever the values of $T$ on the fibre $c^{-1}(c_1)$.

*Proof.* We compute the three entropies.

*Coset.* $c$ is balanced, so $H(c) = \log_2 n$.

*Type.* Let $B = T(c^{-1}(c_1))$ be the set of types occurring on the distinguished fibre; by hypothesis $\tau_0\notin B$. The fibre $T^{-1}(\tau_0)$ is the union of the other $n-1$ fibres of $c$, of total size $k(n-1)$ out of $|S| = kn$, so $P_T(\tau_0) = (n-1)/n$, and
$$H(T) = -\tfrac{n-1}{n}\log_2\tfrac{n-1}{n} + \sum_{t\in B} -P_T(t)\log_2 P_T(t).$$

*Joint.* The values of $(c,T)$ are the pairs $(c_1,t)$ with $t\in B$, and the pairs $(a,\tau_0)$ with $a\ne c_1$; these two families are disjoint. For $t\in B$ the fibre of $(c_1,t)$ coincides with the fibre of $t$ under $T$ (an element of type $t \neq \tau_0$ must lie in $c^{-1}(c_1)$), so the first family contributes exactly the same sum $\sum_{t\in B}-P_T(t)\log_2P_T(t)$. For $a\neq c_1$ the fibre of $(a,\tau_0)$ is the whole fibre $c^{-1}(a)$, of probability $1/n$. Thus
$$H(c,T) = \sum_{t\in B}-P_T(t)\log_2 P_T(t) + (n-1)\cdot\tfrac1n\log_2 n.$$

*Assemble.* The sums over $B$ cancel in $H(c)+H(T)-H(c,T)$, leaving
$$I(c;T) = \log_2 n - \tfrac{n-1}{n}\log_2\tfrac{n-1}{n} - \tfrac{n-1}{n}\log_2 n = \log_2 n - \tfrac{n-1}{n}\log_2(n-1). \qquad\square$$

**Theorem 4.5 (Detector Law, group form).** Let $G$ be a finite group with $n = [G:G'] \ge 2$, let $c$ be a coset readout, and let $T$ be a trivial-coset detector. Then
$$I(c;T) = \delta(n) = h(1/n).$$

*Proof.* Cosets of $G'$ all have size $|G'|$, so $c$ is balanced with $n$ values. Take $c_1 = c(1)$; then $c(g)\ne c_1 \iff g\notin G'$, and Theorem 4.4 applies. $\square$

**Interpretation.** A detector answers exactly one binary question — "is the coset trivial?" — whose answer is "yes" with probability $1/n$. A "yes" leaves no uncertainty; a "no" leaves the $n-1$ nontrivial cosets uniformly likely. The deficit is $H(c\mid T) = \tfrac{n-1}{n}\log_2(n-1)$, and any refinement of $T$ inside $G'$ is invisible to the coset.

### 4.2 Consequences

**Theorem 4.6 (Anti-monotonicity).** If $2\le n<m$ then $\delta(m) < \delta(n)$. Hence, among detector channels, a strictly larger abelianization gives a strictly smaller channel.

*Proof.* The binary entropy $h$ is strictly increasing on $[0,\tfrac12]$, and $0 < 1/m < 1/n \le \tfrac12$. $\square$

**Theorem 4.7 (Vanishing and explicit rate).** $\delta(n)\to0$ as $n\to\infty$, and for all $n\ge2$
$$\delta(n) \le \frac{\log_2 n + 3}{n}.$$
Consequently the realised fraction of the cap satisfies $\delta(n)/\log_2 n \to 0$.

*Proof.* Continuity of $h$ at $0$ with $h(0)=0$ gives $\delta(n) = h(1/n) \to 0$. For the rate, write
$$\delta(n) = \tfrac1n\log_2(n-1) + \frac{\ln\frac{n}{n-1}}{\ln 2}.$$
The first term is at most $\tfrac1n\log_2 n$. For the second, $\ln\frac{n}{n-1}\le\frac{n}{n-1}-1 = \frac{1}{n-1}$, and $\frac{1}{(n-1)\ln 2}\le\frac3n$ for $n\ge2$ because $\ln 2 > 0.693$ implies $3(n-1)\ln 2 \geq n$. Finally, since $\log_2 n\ge1$ and $\delta(n)\ge0$, we have $0\le\delta(n)/\log_2 n\le\delta(n)\to0$. $\square$

The cap $\log_2 n$ diverges while the channel vanishes: large abelian quotients seen through a detector are almost perfectly hidden.

### 4.3 Instances

**Proposition 4.8 (Affine Mersenne groups are detectors).** If $q = 2^k$ and $q-1$ is prime, then the cycle type on $\mathbb{F}_q$ is a trivial-coset detector for $\mathrm{AGL}(1,q)$ with $n = q-1$, and $I_1(\mathrm{AGL}(1,q)) = h\big(1/(q-1)\big)$.

*Proof sketch.* As in Proposition 3.3, $G'$ is the translation group and $G^{ab} \cong \mathbb{F}_q^\times$. As in Proposition 3.5, an element with multiplier $a\ne1$ has exactly one fixed point and its other $q-1$ points split into cycles of length $\mathrm{ord}(a)$; when $q-1$ is prime, $\mathrm{ord}(a) = q-1$ for every $a \neq 1$, so the type is always $[1, q-1]$. Translations have type $[2^{q/2}]$ (nonzero shift) or $[1^q]$ (identity), never $[1,q-1]$ (for $q \geq 4$). $\square$

**Corollary 4.9.** The Detector Law reproduces:

- $\mathrm{AGL}(1,8)$, $n = 7$: $\delta(7) = \log_2 7 - \tfrac67\log_2 6$, the value of Theorem 3.6.
- $A_4\cong\mathrm{AGL}(1,4)$, $n=3$: the $3$-cycles (the type "one fixed point plus a $3$-cycle", i.e. one linear factor times an irreducible cubic) are exactly the elements outside $V_4 = A_4'$, so $I_1(A_4) = \delta(3) = \log_2 3 - \tfrac23\approx 0.918$.
- $V_4$ acting regularly on four points, $n=4$ (here $G' = 1$): every non-identity element has type $[2,2]$, so $I_1(V_4) = \delta(4) = 2 - \tfrac34\log_2 3\approx 0.811$.

**Corollary 4.10 ($\mathrm{AGL}(1,8)$ leaks less than $A_4$, without numerics).** Both are detectors and $7>3$; by Theorem 4.6, $I_1(\mathrm{AGL}(1,8)) < I_1(A_4)$. Also $I_1(\mathrm{AGL}(1,8)) \le (\log_2 7 + 3)/7$ by Theorem 4.7.

Along the Mersenne ladder $n = 3, 7, 31, 127, 8191,\dots$ the prime channel is
$$0.918,\quad 0.592,\quad 0.206,\quad 0.066,\quad 0.0018,\ \dots \text{ bits},$$
realising $57.9\%, 21.1\%, 4.15\%, 0.95\%, 0.014\%$ of the cap.

---

## 5. The extended reversal

We compare with the small Galois groups that had been studied previously, each acting on the roots of a quartic (or quintic), with the cycle type as type readout and the canonical abelianization map as coset readout. The prime channels below are exact closed forms: $S_3$ and $S_4$ give $1$ (the type determines the sign); $A_4$ gives $\log_2 3 - \tfrac23$; $D_4$ gives $\approx 1.656$; $V_4$ gives $2 - \tfrac34\log_2 3$; $C_4$ gives $\tfrac32$. Semiprime values are computed by exhaustive enumeration of $G\times G$.

| group | $\lvert G\rvert$ | $\lvert G^{ab}\rvert$ | cap | $I_1$ | $I_1$/cap | $I_2$ | $I_2$/cap |
|---|---|---|---|---|---|---|---|
| $S_3$ | 6 | 2 | 1.000 | 1.000 | 100% | 1.000 | 100% |
| $S_4$ | 24 | 2 | 1.000 | 1.000 | 100% | 1.000 | 100% |
| $D_5$ | 10 | 2 | 1.000 | 1.000 | 100% | 1.000 | 100% |
| $A_4$ | 12 | 3 | 1.585 | 0.918 | 57.9% | 0.474 | 29.9% |
| $D_4$ | 8 | 4 | 2.000 | 1.656 | 82.8% | 1.430 | 71.5% |
| $C_4$ | 4 | 4 | 2.000 | 1.500 | 75.0% | 1.250 | 62.5% |
| $V_4$ | 4 | 4 | 2.000 | 0.811 | 40.6% | 0.295 | 14.7% |
| $\mathrm{AGL}(1,8)$ | 56 | 7 | 2.807 | 0.592 | 21.1% | 0.114 | 4.1% |

**Theorem 5.1 (Largest cap, smallest channel).** Against each of $S_3, S_4, A_4, D_4, V_4, C_4$, the group $\mathrm{AGL}(1,8)$ has a strictly larger cap ($\log_2 7>2$) and a strictly smaller prime channel. Its realised fraction of the cap ($<21.1\%$) is strictly below that of each of these groups, the next smallest being $V_4$ ($>40\%$).

*Proof.* Compare Theorem 3.6 with the closed forms above, using rational bounds on $\log_2 3$ and $\log_2 7$; the comparison with $A_4$ is Corollary 4.10. $\square$

**Theorem 5.2 (Semiprime reversal).** $4\,I_2(\mathrm{AGL}(1,8)) < I_2(A_4) = \log_2 3 - \tfrac{10}{9}$, and $8\,I_2(\mathrm{AGL}(1,8)) < I_2(D_5) = 1$.

*Proof sketch.* For $A_4$ an enumeration of the $144$ pairs gives $I_2(A_4) = \log_2 3 - \tfrac{10}{9} \approx 0.4739$ (so pairing costs $A_4$ exactly $\tfrac49$ of a bit). For the dihedral quintic group $D_5$ (abelianization $C_2$) the type determines whether an element is a rotation or a reflection, so the unordered type pair determines the parity of the product, giving one full bit. Compare with Theorem 3.9. $\square$

**Corollary 5.3 (Non-monotonicity in the abelianization).** Neither $I_1$ nor $I_2$ is monotone in $|G^{ab}|$: $|A_4^{ab}| = 3 < 7$ yet $I_1(A_4) > I_1(\mathrm{AGL}(1,8))$; $|D_5^{ab}| = 2<7$ yet $I_2(D_5)>I_2(\mathrm{AGL}(1,8))$.

**Discussion.** By Proposition 2.6, every row of the table is "cap minus deficit." The cap is fixed by $|G^{ab}|$; the deficit $H(c\mid T)$ measures how coarsely the class function $T$ sees the abelian quotient. $D_4$'s type distinguishes its four cosets well and loses little; $\mathrm{AGL}(1,8)$'s type merges six of seven cosets and loses $\tfrac67\log_2 6\approx 2.216$ of its $2.807$ bits. The operative quantity is not $|G|$, nor $|G^{ab}|$, but **how much of $G^{ab}$ the class function resolves**, i.e. $I(c;T)$ itself — and the Detector Law shows that for the coarsest nontrivial resolution this quantity *decreases* as $|G^{ab}|$ grows.

---

## 6. Two conjectures and their evidence

### 6.1 The pair-detector formula

**Conjecture 6.1 (Pair-Detector Law).** Let $G$ be a finite group with $n = |G^{ab}| \ge 3$ and let $T$ be a trivial-coset detector. Then
$$I_2(G) = \delta_2(n) := \log_2 n - \frac{2(n-1)}{n^2}\log_2(n-1) - \Big(\frac{n-1}{n}\Big)^2 H_n,$$
where
$$H_n = \frac{1}{n-1}\log_2(n-1) + \frac{n-2}{n-1}\log_2\frac{(n-1)^2}{n-2}$$
is the entropy of the sum of two independent uniform nonzero elements of an abelian group of order $n$.

*Heuristic.* As in Theorem 3.9, the unordered type pair determines how many of $x,y$ lie outside $G'$, and nothing else relevant to $c(xy)$. With probability $1/n^2$ both lie in $G'$ and the product coset is trivial; with probability $2(n-1)/n^2$ exactly one does, and the product coset is uniform on the $n-1$ nontrivial values; with probability $((n-1)/n)^2$ neither does, and the product coset is the sum of two independent uniform nontrivial elements, which equals $0$ with probability $1/(n-1)$ and each nonzero value with probability $(n-2)/(n-1)^2$ (for $a \neq 0$, exactly $n-2$ pairs of nonzero elements sum to $a$). Subtracting the averaged conditional entropy from $\log_2 n$ gives $\delta_2(n)$.

*Evidence.* The formula agrees exactly with the closed forms at $n=3$ ($A_4$: $\delta_2(3) = \log_2 3 - \tfrac{10}{9}$) and $n = 7$ ($\mathrm{AGL}(1,8)$: $\delta_2(7) = \log_2 7 - \tfrac{78}{49}\log_2 6 + \tfrac{30}{49}\log_2 5$, using $\log_2\tfrac{36}{5} = 2\log_2 6 - \log_2 5$). Enumeration also gives agreement for $V_4$ at $n=4$ ($0.29474$), whose abelianization is not cyclic. Exhaustive enumeration of all $992^2 = 984{,}064$ pairs of $\mathrm{AGL}(1,32)$ gives $I_2 \approx 0.0081335$, again equal to $\delta_2(31)$.

### 6.2 The resolved-quotient (totient) formula

**Conjecture 6.2 (Coarsest-Resolved-Quotient Law).** Suppose $T$ determines exactly a function $\rho$ of the coset, in the sense that $T(g)$ determines $\rho(c(g))$, and the additional information in $T$ never distinguishes two elements of different cosets with the same $\rho$-value. Then
$$I(c;T) = H\big(\rho(c)\big).$$
For $\mathrm{AGL}(1,q)$, $\rho$ is the multiplicative order of the multiplier; since $\mathbb{F}_q^\times$ is cyclic of order $q-1$, exactly $\varphi(d)$ multipliers have order $d$ for each $d\mid q-1$, giving
$$I_1(\mathrm{AGL}(1,q)) = \log_2(q-1) - \sum_{d\mid q-1}\frac{\varphi(d)}{q-1}\log_2\varphi(d).$$

The Detector Law is the case where $\rho$ is the indicator of the trivial coset. The formula holds at $q = 5, 7$ (previously) and $q = 8$ (Remark 3.7). Exhaustive computation of the cycle types of $\mathrm{AGL}(1,q)$ for every prime power $q\le32$ agrees with the formula in every case; for instance
$$q=9:\ 1.75,\quad q=13:\ 2.4183,\quad q=16:\ 1.6402,\quad q=32:\ 0.2056 \text{ bits}.$$

---

## 7. Algorithms

The exact values above are obtained by three elementary procedures.

**Algorithm A (Exact channel by enumeration).** *Input:* a finite list $S$, readouts $c,T$. *Output:* $I(c;T)$.
1. Count the multisets $\{c(s)\}$, $\{T(s)\}$, $\{(c(s),T(s))\}$ in hash maps.
2. Convert counts to exact rationals $m/|S|$ and evaluate $H = -\sum p\log_2 p$ for each.
3. Return $H(c)+H(T)-H(c,T)$.

Cost: $O(|S|)$ readout evaluations and dictionary operations. For the semiprime channel $|S| = |G|^2$ ($3136$ for $\mathrm{AGL}(1,8)$). For closed forms one writes each count as $2^i3^j5^k7^l$ and expands the logarithms into integer combinations of $\log_2 3, \log_2 5, \log_2 7$.

**Algorithm B (Affine group construction).** *Input:* a prime power $q = p^k$. *Output:* $\mathrm{AGL}(1,q)$ as permutations with coset labels.
1. Find a monic irreducible polynomial of degree $k$ over $\mathbb{F}_p$; build addition and multiplication tables of $\mathbb{F}_q$.
2. Find a primitive element $g$ and tabulate $\log_g$.
3. For each $a\ne0$, $b$, record the permutation $t\mapsto at+b$ and its coset label $\log_g a$.

Cost: $O(q^2)$ table entries plus $O(q^3)$ to list the group.

**Algorithm C (Derived subgroup certificate).** Close the set of commutators $\{xyx^{-1}y^{-1}\}$ under multiplication and compare with the translation subgroup; check that $\log_g$ of the multiplier is a homomorphism with this kernel. Cost: $O(|G|^2)$ commutators.

**Algorithm D (Detector value and rate).** Evaluate $\delta(n) = \log_2 n - \tfrac{n-1}{n}\log_2(n-1)$ and the bound $(\log_2 n+3)/n$ in $O(1)$.

---

## 8. Applications and limitations

**Cryptographic reading.** For an RSA-type modulus $N = pq$ and a fixed auxiliary polynomial $f$ with Galois group $G$, the splitting types of $f$ modulo $p$ and $q$ are, heuristically, independent Chebotarev samples. The semiprime channel quantifies what these would reveal about the residue of $N$ in $G^{ab}$. Two features make this harmless for factoring:

1. The leakage is bounded by $\log_2|G^{ab}|$, a constant for fixed $f$, whereas pinning down a factor of $N$ requires $\Theta(\log N)$ bits.
2. The leaked quantity is a residue of $N$ itself, which is public. The mechanism is real, but it measures the wrong quantity.

The Detector Law sharpens the picture: for the natural families with ever larger abelian quotients (affine Mersenne groups), the channel *decays* to zero.

**Information-theoretic reading.** The Detector Law is a general statement about a balanced variable observed through a test that detects a single value. It applies verbatim outside group theory: whenever an observation reveals only "is the hidden uniform $n$-ary variable equal to its distinguished value, and if so some irrelevant extra detail," the information is $h(1/n)$.

**Design reading.** If one wants a class function that resolves an abelian quotient well, the lesson is to avoid groups where the quotient's elements all have the same order. Affine groups with $q-1$ highly composite (e.g. $\mathrm{AGL}(1,13)$, where $12$ has many divisors) resolve far more of the cap than Mersenne cases.

---

## 9. Future directions

1. **Pair-Detector Law** (Conjecture 6.1) in full generality, for all finite groups with a detector type readout.
2. **Coarsest-Resolved-Quotient Law** (Conjecture 6.2), which would turn the totient formula for $\mathrm{AGL}(1,q)$ into a theorem for every prime power $q$.
3. **Mersenne vanishing with explicit rate**: along $\mathrm{AGL}(1,2^p)$ with $2^p-1$ prime, $I_1\le(p+3)/(2^p-1)$ is a consequence of Theorem 4.7; the conjecture is that $n I_2/I_1\to1$, i.e. the semiprime channel is of order $(\log n)/n^2$. Numerically the ratio $n\delta_2(n)/\delta(n)$ is $1.35$ at $n=7$, $1.17$ at $n=127$, and $1.08$ at $n=131071$, decreasing slowly.
4. **Beyond affine groups**: groups with large abelianization whose class functions resolve it finely; is there a sharp upper bound for $I_1/\log_2|G^{ab}|$ in terms of the number of conjugacy classes?

---

## 10. Conclusion

The first group examined with an abelianization of order larger than four, $\mathrm{AGL}(1,8)$, has the largest cap and the smallest channel of all groups studied, at both the prime and semiprime levels. The explanation is a one-line identity — the Detector Law $I = h(1/|G^{ab}|)$ — which holds for every finite group whose type readout sees only whether an element lies in the derived subgroup. It is anti-monotone in the size of the abelianization and tends to zero. The leak of a splitting-type channel is governed not by the size of the group or of its abelian quotient, but by how much of that quotient the class function resolves.

---

## Appendix: Numerical summary

| quantity | exact value | numerical |
|---|---|---|
| cap of $\mathrm{AGL}(1,8)$ | $\log_2 7$ | $2.80735$ |
| $I_1(\mathrm{AGL}(1,8))$ | $\log_2 7 - \tfrac67\log_2 6 = h(1/7)$ | $0.59167$ |
| deficit $H(c\mid T)$ | $\tfrac67\log_2 6$ | $2.21568$ |
| $I_2(\mathrm{AGL}(1,8))$ | $\log_2 7 - \tfrac{78}{49}\log_2 6 + \tfrac{30}{49}\log_2 5$ | $0.11411$ |
| $I_1(A_4)$ | $\log_2 3 - \tfrac23$ | $0.91830$ |
| $I_2(A_4)$ | $\log_2 3 - \tfrac{10}{9}$ | $0.47385$ |
| $I_1(V_4)$ | $2 - \tfrac34\log_2 3$ | $0.81128$ |
| rate bound at $n=7$ | $(\log_2 7+3)/7$ | $0.82962$ |
