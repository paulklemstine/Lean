# The $D_6$ Splitting-Type Channel of $x^6 - 2$: Exact Entropies, an Abelian Ceiling, and a Non-Abelian Residue

**Aristotle**

*September 2026*

---

## Abstract

For a prime $p \ge 5$, let $T(p)$ be the number of roots of $x^6 - 2$ in $\mathbb{F}_p$. Empirically $T(p)$ takes only the values $0, 2, 6$, with frequencies near $66\%, 25\%, 8\%$. Its Shannon entropy is about $1.18$ bits, the residue $p \bmod 3$ shares about $0.363$ bits with it, and for semiprimes $N = pq$ the residue $N \bmod 3$ shares about $0.132$ bits with the type pair. We explain all of these numbers exactly. The splitting field has Galois group the dihedral group $D_6$ of order $12$, acting on the six roots as on the vertices of a regular hexagon. Assuming Chebotarev equidistribution, $T$ is distributed as the number of fixed vertices of a uniformly random element of $D_6$. We prove:

1. The fixed-point law of $D_n$ for every even $n$. For $D_6$ it gives the type distribution $\{0 : 8,\ 2 : 3,\ 6 : 1\}/12$.
2. An unconditional prime-level root law. $T(p) \in \{0,6\}$ when $p \equiv 1 \pmod 3$, and $T(p) = 2\cdot[p \equiv \pm 1 \pmod 8]$ when $p \equiv 2 \pmod 3$. Together these give a complete congruence table modulo $24$ in which exactly the classes $1, 7 \pmod{24}$ remain undetermined.
3. Closed forms: $H(T) = \tfrac34\log_2 3$, $I(p \bmod 3; T) = \tfrac14\log_2 3 + \tfrac5{12}\log_2 5 - 1$, and $I(D_6^{ab}; T) = \tfrac12\log_2 3 + \tfrac16$. For the semiprime pair channel, $I_{\mathrm{pair}} = \tfrac38\log_2 3 + \tfrac{35}{72}\log_2 5 + \tfrac{17}{72}\log_2 17 - \tfrac{23}{9}$.
4. An abelian ceiling valid for every finite group. No dial that factors through an abelian quotient carries more information than the abelianisation. For $D_6$, every such dial leaves a non-abelian residue of at least $\tfrac14\log_2 3 - \tfrac16 > 0.22$ bits.
5. Information and prediction come apart. The dial $p \bmod 3$ carries $0.36$ bits yet does not lower the Bayes error below $1/3$. Every abelian dial misclassifies at least $1/12$ of Frobenius classes, and $p \bmod 24$ attains this floor.

The structural source of the residue is the commutator identity $[r_1, s_0] = r_2$.

---

## 1. Introduction

A polynomial $f \in \mathbb{Z}[x]$ and a prime $p$ give a basic arithmetic statistic: the number of roots of $f$ modulo $p$. For an irreducible $f$ with splitting field $K$ and Galois group $G$ acting on the roots, this count equals the number of roots fixed by the Frobenius element $\mathrm{Frob}_p \in G$, for $p$ unramified in $K$. The Chebotarev density theorem says that $\mathrm{Frob}_p$ is equidistributed over $G$ (conjugacy classes weighted by size). Root-count statistics are therefore *fixed-point statistics of a uniformly random group element*.

We call the resulting random variable the **type** $T$. A **dial** is any coarse function of the prime, such as a residue $p \bmod m$, whose information content about $T$ we want to measure. This gives a *type channel*: the source is a uniformly random element of $G$, the output is $T$, and a dial is a side observation. When $G$ is abelian, class field theory says congruence conditions see everything about $\mathrm{Frob}_p$. The first interesting test is therefore a non-abelian $G$.

This paper treats the case $f = x^6 - 2$, with $G = D_6$. Every experimental value in this setting turns out to be an exact, closed-form quantity attached to $D_6$. More importantly, a sharp and fully general inequality (the *abelian ceiling*) quantifies how much of $T$ congruences can never see. For $x^6 - 2$ this unreachable part is $\tfrac14\log_2 3 - \tfrac16 \approx 0.2296$ bits, about $19.3\%$ of $H(T)$.

**Standing hypothesis.** The one analytic input is Chebotarev equidistribution of $\mathrm{Frob}_p$ in $D_6$, which we use as a modelling hypothesis and do not re-prove. All group-side statements are exact. The prime-level root law of Section 4 is unconditional and holds for every prime, so it serves as a direct check on the group-side model.

---

## 2. The splitting field and its Galois group

Let $\alpha = 2^{1/6} > 0$ and $\zeta = e^{2\pi i /6}$, so that $\zeta = \tfrac{1 + \sqrt{-3}}{2}$. The roots of $x^6 - 2$ are $\zeta^j\alpha$ for $j \in \mathbb{Z}/6$. The splitting field is
$$K = \mathbb{Q}(\alpha, \zeta) = \mathbb{Q}(2^{1/6}, \sqrt{-3}), \qquad [K:\mathbb{Q}] = 12.$$

**Definition 2.1 (dihedral group and vertex action).** For $n \ge 1$, the dihedral group $D_n$ of order $2n$ consists of rotations $r_i$ and reflections $s_i$, $i \in \mathbb{Z}/n$, with multiplication
$$r_i r_j = r_{i+j},\quad r_i s_j = s_{j-i},\quad s_i r_j = s_{i+j},\quad s_i s_j = r_{j-i}.$$
It acts on $\mathbb{Z}/n$ (the vertices of a regular $n$-gon) by
$$r_i \cdot j = i + j, \qquad s_i \cdot j = -i - j.$$

**Lemma 2.2.** This is a group action: $r_0 \cdot j = j$ and $(gh)\cdot j = g\cdot(h \cdot j)$ for all $g, h \in D_n$ and $j \in \mathbb{Z}/n$.

*Proof.* Check the four cases of $(g,h)$. For example, $s_i\cdot(s_k\cdot j) = -i - (-k - j) = (k - i) + j = r_{k-i}\cdot j = (s_is_k)\cdot j$, and $r_i \cdot (s_k \cdot j) = i - k - j = -(k-i) - j = s_{k-i}\cdot j = (r_i s_k)\cdot j$. The remaining two cases are similar. $\square$

For $x^6 - 2$, the Galois automorphism $\sigma$ with $\sigma(\alpha) = \zeta^i\alpha$ and $\sigma(\sqrt{-3}) = \sqrt{-3}$ acts on root indices by $j \mapsto j + i$: this is $r_i$. The automorphism with $\sigma(\alpha) = \zeta^{-i}\alpha$ and $\sigma(\sqrt{-3}) = -\sqrt{-3}$ (so $\sigma(\zeta) = \zeta^{-1}$) acts by $j \mapsto -i - j$: this is $s_i$. Hence $\mathrm{Gal}(K/\mathbb{Q}) \cong D_6$, acting on the roots as on the vertices of a hexagon.

**Definition 2.3 (type).** For $g \in D_n$ let $\mathrm{fix}(g) = \#\{j \in \mathbb{Z}/n : g \cdot j = j\}$. For an unramified prime $p$ (here $p \ge 5$), the type of $p$ is
$$T(p) = \#\{x \in \mathbb{F}_p : x^6 = 2\} = \mathrm{fix}(\mathrm{Frob}_p).$$

---

## 3. Group-theoretic core

### 3.1 The fixed-point law of $D_n$ for even $n$

**Theorem 3.1 (rotations).** For every $n \ge 1$ and $i \in \mathbb{Z}/n$: $\mathrm{fix}(r_i) = n$ if $i = 0$, and $\mathrm{fix}(r_i) = 0$ otherwise.

*Proof.* $i + j = j$ holds if and only if $i = 0$. $\square$

**Theorem 3.2 (reflections, $n$ even).** Let $n$ be even and $i \in \mathbb{Z}/n$ with representative $0 \le i < n$. Then $\mathrm{fix}(s_i) = 2$ if $i$ is even, and $\mathrm{fix}(s_i) = 0$ if $i$ is odd.

*Proof.* The fixed points of $s_i$ are the solutions of $2j = -i$ in $\mathbb{Z}/n$. The doubling map $j \mapsto 2j$ is an additive endomorphism of the cyclic group $\mathbb{Z}/n$. Its kernel has $\gcd(n, 2) = 2$ elements, so every nonempty fibre has exactly $2$ elements. The element $-i$ lies in the image if and only if $i$ is even. Reducing $2j = -i$ modulo $2$ (legitimate since $2 \mid n$) forces $i \equiv 0 \pmod 2$. Conversely, if $i = 2t$ then $j = -t$ is a solution. $\square$

**Corollary 3.3.** For even $n$, every element of $D_n$ has $0$, $2$ or $n$ fixed vertices.

### 3.2 The $D_6$ type distribution

**Theorem 3.4.** In $D_6$, exactly $8$ elements fix no vertex, $3$ fix two vertices, and $1$ fixes all six. That is, under the uniform distribution on $D_6$,
$$\Pr[T = 0] = \tfrac23, \qquad \Pr[T = 2] = \tfrac14, \qquad \Pr[T = 6] = \tfrac1{12}.$$
The elements with $T = 0$ are $r_1, \dots, r_5, s_1, s_3, s_5$, those with $T = 2$ are $s_0, s_2, s_4$, and $T = 6$ only for $r_0$.

*Proof.* Immediate from Theorems 3.1 and 3.2. $\square$

**Remark 3.5 (Burnside check).** $\sum_{g \in D_6} \mathrm{fix}(g) = 8\cdot 0 + 3 \cdot 2 + 1 \cdot 6 = 12 = |D_6|$. By Burnside's lemma, this says the action on the six roots has a single orbit, as it must, since $x^6 - 2$ is irreducible.

### 3.3 Characters seen by congruence dials

**Definition 3.6.** The **rotation character** $\rho: D_n \to \mathbb{Z}/2$ is $\rho(r_i) = 0$ and $\rho(s_i) = 1$. For even $n$, the **abelianisation map** $\pi: D_n \to \mathbb{Z}/2 \times \mathbb{Z}/2$ is
$$\pi(r_i) = (0,\ i \bmod 2), \qquad \pi(s_i) = (1,\ i \bmod 2).$$

**Proposition 3.7.** $\rho$ and $\pi$ are group homomorphisms, and the first coordinate of $\pi$ is $\rho$.

*Proof.* Direct verification on the four product types, using that $-i \equiv i \pmod 2$. $\square$

*Arithmetic meaning.* For $G = \mathrm{Gal}(K/\mathbb{Q})$, $\rho(\mathrm{Frob}_p)$ records the action of $\mathrm{Frob}_p$ on $\sqrt{-3}$, which is the Legendre symbol $\left(\tfrac{-3}{p}\right)$. It is trivial exactly when $p \equiv 1 \pmod 3$. The second coordinate of $\pi$ records the action on $\sqrt2 = \alpha^3$. Indeed $r_i(\alpha^3) = \zeta^{3i}\alpha^3 = (-1)^i\sqrt 2$, and similarly for $s_i$. That coordinate is trivial exactly when $p \equiv \pm 1 \pmod 8$. Thus $\pi(\mathrm{Frob}_p)$ is determined by $p \bmod 24$. It is the Frobenius in $\mathrm{Gal}(\mathbb{Q}(\sqrt{-3}, \sqrt2)/\mathbb{Q})$.

**Proposition 3.8 (commutator).** In every $D_n$, $[r_1, s_0] := r_1 s_0 r_1^{-1} s_0^{-1} = r_2$.

**Corollary 3.9.** In $D_6$ the kernel of $\pi$ is $\{r_0, r_2, r_4\}$, and it lies in the commutator subgroup. Two elements of $D_6$ have the same image under $\pi$ if and only if they have the same image in the abstract abelianisation $D_6^{ab}$. In particular $D_6^{ab} \cong \mathbb{Z}/2 \times \mathbb{Z}/2$ via $\pi$.

*Proof.* Since $r_2$ is a commutator, it maps to the identity in $D_6^{ab}$, and so does $r_4 = r_2^2$. If $\pi(g) = \pi(h)$ then $g = r_k h$ with $k \in \{0,2,4\}$, so $g$ and $h$ agree in $D_6^{ab}$. Conversely, $\pi$ is a homomorphism to an abelian group, so it factors through $D_6^{ab}$. $\square$

---

## 4. The prime-level root law (unconditional)

**Theorem 4.1 (cyclic root law).** Let $C$ be a finite cyclic group of order $n$, let $k \ge 0$, and let $a \in C$. Then the equation $x^k = a$ has either $0$ or exactly $\gcd(n, k)$ solutions in $C$.

*Proof.* The map $x \mapsto x^k$ is a homomorphism. If $a$ is in its image, the solution set is a coset of the kernel. In a cyclic group of order $n$ the kernel of the $k$-th power map has $\gcd(n, k)$ elements. $\square$

**Corollary 4.2 (finite fields).** In a finite field $\mathbb{F}_q$, for $a \ne 0$ and $k \ge 1$, the equation $x^k = a$ has $0$ or $\gcd(q - 1, k)$ solutions.

*Proof.* Any solution is nonzero, and $\mathbb{F}_q^\times$ is cyclic of order $q - 1$. $\square$

**Theorem 4.3 (dichotomy).** For every odd prime $p$, $T(p) \in \{0,\ \gcd(p - 1, 6)\}$.

**Theorem 4.4 (rotation half).** If $p$ is prime with $p \equiv 1 \pmod 3$, then $T(p) \in \{0, 6\}$.

*Proof.* Such $p$ is odd, so $6 \mid p - 1$. Apply Theorem 4.3. $\square$

**Theorem 4.5 (reflection half).** If $p \ne 2$ is prime with $p \equiv 2 \pmod 3$, then
$$T(p) = \begin{cases} 2 & p \equiv \pm 1 \pmod 8,\\ 0 & \text{otherwise.}\end{cases}$$

*Proof.* Here $\gcd(p - 1, 6) = 2$, so $T(p) \in \{0, 2\}$. It remains to decide when a sixth root of $2$ exists. If $x^6 = 2$ then $(x^3)^2 = 2$, so $2$ is a square. Conversely, suppose $y^2 = 2$. Since $3 \nmid p - 1$, choose $e$ with $3e = 2(p-1) + 1$. Then $(y^e)^6 = (y^{3e})^2 = (y^{p-1} \cdot y^{p-1}\cdot y)^2 = y^2 = 2$ by Fermat. So a sixth root exists if and only if $2$ is a square modulo $p$. By the second supplementary law of quadratic reciprocity, that happens if and only if $p \equiv \pm 1 \pmod 8$. $\square$

**Theorem 4.6 (the complete congruence picture at conductor 24).** For every prime $p \ge 5$:
- if $p \equiv 5, 11, 13, 19 \pmod{24}$ then $T(p) = 0$;
- if $p \equiv 17, 23 \pmod{24}$ then $T(p) = 2$;
- if $p \equiv 1, 7 \pmod{24}$ then $T(p) \in \{0, 6\}$.

*Proof.* In the first case $p \equiv \pm 3 \pmod 8$, so $2$ is not a square modulo $p$. Since $x^6 = 2$ would give $(x^3)^2 = 2$, we get $T(p) = 0$. The second case is Theorem 4.5, and the third is Theorem 4.4. $\square$

**Remark 4.7.** In the last case both values occur. The least prime $p \ge 5$ with $T(p) = 6$ is $p = 31$: from $2^5 = 32 \equiv 1$ we get $2^6 \equiv 2$, and $\gcd(30, 6) = 6$. Small values for comparison: $T(5) = T(7) = T(11) = T(13) = T(19) = 0$ and $T(23) = T(47) = 2$. Whether $T(p) = 0$ or $6$ for $p \equiv 1, 7 \pmod{24}$ depends on whether $2$ is a sixth power modulo $p$, which is not a congruence condition on $p$. This is the arithmetic face of Corollary 3.9. The class $\{r_0, r_2, r_4\}$ has types $6, 0, 0$, and no abelian quotient separates its elements.

Theorems 3.1–3.4 and 4.4–4.6 agree exactly. Rotations ($p \equiv 1 \bmod 3$) have $0$ or $6$ fixed roots, and reflections ($p \equiv 2 \bmod 3$) have $0$ or $2$.

---

## 5. A counting information calculus

All entropies are in bits ($\log_2$). Throughout, $S$ is a finite nonempty set equipped with the uniform distribution, $g: S \to B$ is a read-out, and $k: S \to C$ is a dial.

**Definition 5.1.** 
- The **entropy** of $g$ on $S$ is $H_S(g) = -\sum_{b} \frac{|g^{-1}(b)|}{|S|}\log_2\frac{|g^{-1}(b)|}{|S|}$.
- The **conditional entropy** is 
$$H_S(g \mid k) = \sum_{c \in k(S)} \frac{|S_c|}{|S|}\, H_{S_c}(g), \qquad S_c = \{x \in S : k(x) = c\}.$$
- The **mutual information** is $I_S(g; k) = H_S(g) - H_S(g \mid k)$.

A convenient way to compute: if the fibre sizes of $g$ on $S$ are $m_1, \dots, m_t$ with $\sum m_i = M$, then
$$H_S(g) = \log_2 M - \frac1M\sum_i m_i \log_2 m_i. \tag{5.1}$$

**Lemma 5.2 (average form).** $H_S(g \mid k) = \frac{1}{|S|}\sum_{a \in S} H_{S_{k(a)}}(g)$.

*Proof.* Group the sum over $a$ by the value $c = k(a)$. Each fibre $S_c$ contributes $|S_c|$ equal terms. $\square$

**Lemma 5.3 (Gibbs).** $0 \le H_S(g \mid k) \le H_S(g)$. Equivalently, $I_S(g;k) \ge 0$.

**Theorem 5.4 (refinement monotonicity).** Let $k: S \to C$ and $k': S \to C'$ be dials such that $k'$ refines $k$ on $S$, that is, $k'(a) = k'(b)$ implies $k(a) = k(b)$. Then
$$H_S(g \mid k') \le H_S(g \mid k), \qquad\text{equivalently}\qquad I_S(g; k) \le I_S(g; k').$$

*Proof.* By refinement, each $k$-fibre $S_c$ is a disjoint union of $k'$-fibres, and on $S_c$ the restriction of $k'$ is a dial. Lemma 5.3 applied inside $S_c$ gives $H_{S_c}(g \mid k'|_{S_c}) \le H_{S_c}(g)$. Since the $k'$-fibres inside $S_c$ are exactly the $k'$-fibres of $S$ contained in $S_c$, averaging over $c$ with weights $|S_c|/|S|$ turns the left side into $H_S(g \mid k')$ and the right side into $H_S(g \mid k)$. $\square$

**Corollary 5.5.** Two dials with the same level-set partition of $S$ have equal conditional entropies.

**Theorem 5.6 (abelian ceiling).** Let $G$ be a finite group with the uniform distribution, let $g$ be any read-out on $G$, and let $\varphi: G \to A$ be any homomorphism to an abelian group. Then
$$I_G(g; \varphi) \le I_G(g; \mathrm{ab}), \qquad \mathrm{ab}: G \to G^{ab} = G/[G,G].$$

*Proof.* By the universal property of the abelianisation, $\varphi = \bar\varphi \circ \mathrm{ab}$. So $\mathrm{ab}(x) = \mathrm{ab}(y)$ implies $\varphi(x) = \varphi(y)$, that is, $\mathrm{ab}$ refines $\varphi$. Apply Theorem 5.4. $\square$

*Arithmetic reading.* For a Galois extension $K/\mathbb{Q}$, a dial of the form $p \bmod m$ observes $\mathrm{Frob}_p$ only through $\mathrm{Gal}(K \cap \mathbb{Q}(\zeta_m)/\mathbb{Q})$, an abelian quotient of $\mathrm{Gal}(K/\mathbb{Q})$. More generally, by the Kronecker–Weber theorem every abelian quotient corresponds to a subfield of a cyclotomic field. Under Chebotarev equidistribution, therefore, *no congruence dial of any modulus* carries more information about any Frobenius statistic than the abelianisation dial.

---

## 6. Exact values of the $D_6$ type channel

Write $L = \log_2 3$, $L_5 = \log_2 5$, $L_{17} = \log_2 17$. Take $S = D_6$ with the uniform distribution and read-out $T = \mathrm{fix}$.

**Theorem 6.1 (type entropy).**
$$H(T) = \tfrac34 L \approx 1.18872.$$

*Proof.* The fibre sizes are $1, 8, 3$ with $M = 12$. By (5.1), $H(T) = \log_2 12 - \tfrac{1}{12}(8\cdot 3 + 3 L) = 2 + L - 2 - \tfrac14 L = \tfrac34 L$. $\square$

**Theorem 6.2 (conductor-3 dial).** With the dial $\rho$ (equivalently $p \bmod 3$):
- on the rotation fibre (types $\{6:1, 0:5\}$), $H = 1 + L - \tfrac56 L_5$;
- on the reflection fibre (types $\{2:3, 0:3\}$), $H = 1$;
- $H(T \mid \rho) = 1 + \tfrac12 L - \tfrac5{12}L_5$;
$$I(\rho; T) = \tfrac14 L + \tfrac5{12} L_5 - 1 \approx 0.36371.$$
Moreover $0.34 < I(\rho;T) < 0.375$ and $0 < I(\rho; T) < H(T)$. The channel is *leaking*: informative, but it does not pin down the type.

*Proof.* On the rotation fibre, (5.1) with sizes $1, 5$ gives $\log_2 6 - \tfrac56 L_5 = 1 + L - \tfrac56 L_5$. On the reflection fibre, sizes $3, 3$ give one bit. Both fibres have weight $\tfrac12$. The enclosure uses $\tfrac{19}{12} < L < \tfrac{8}{5}$ and elementary rational bounds on $L_5$. For instance $L > 19/12$ is equivalent to $3^{12} = 531441 > 2^{19} = 524288$. $\square$

**Theorem 6.3 (full abelian dial).** With the dial $\pi$ (equivalently $p \bmod 24$):
$$H(T \mid \pi) = \tfrac14 L - \tfrac16 \approx 0.22957, \qquad I(\pi; T) = \tfrac12 L + \tfrac16 \approx 0.95915.$$

*Proof.* The four fibres of $\pi$ are $\{r_0,r_2,r_4\}$ with types $\{6,0,0\}$, $\{r_1,r_3,r_5\}$ with all types $0$, $\{s_0,s_2,s_4\}$ with all types $2$, and $\{s_1,s_3,s_5\}$ with all types $0$. Only the first fibre has positive entropy, namely $\log_2 3 - \tfrac23$. It has weight $\tfrac14$. $\square$

**Theorem 6.4 (abelian ceiling and non-abelian residue for $D_6$).** For every homomorphism $\varphi$ of $D_6$ into an abelian group,
$$I(\varphi; T) \le \tfrac12 L + \tfrac16, \qquad H(T \mid \varphi) \ge \tfrac14 L - \tfrac16 > 0.22.$$
In particular no abelian dial determines the type.

*Proof.* By Corollaries 3.9 and 5.5, $\pi$ and the abstract abelianisation induce the same channel. Apply Theorem 5.6 and Theorem 6.3. For the numerical bound, $\tfrac14 L - \tfrac16 > \tfrac{19}{48} - \tfrac{8}{48} = \tfrac{11}{48} > 0.229$. $\square$

**Corollary 6.5 (dial hierarchy).**
$$0 < I(p \bmod 3; T) < I(p \bmod 24; T) < H(T).$$
Numerically this reads $0 < 0.364 < 0.959 < 1.189$. The abelian ceiling captures the fraction $\frac{L/2 + 1/6}{3L/4} \approx 0.807$ of the type entropy.

---

## 7. The semiprime pair channel

For a semiprime $N = pq$ with $p, q \ge 5$ distinct, the experiment records the type pair $(T(p), T(q))$ and the dial $N \bmod 3$. Under Chebotarev, applied independently to the two primes, the pair of Frobenii is uniform on $D_6 \times D_6$ ($144$ elements). The dial $N \bmod 3 = (p \bmod 3)(q \bmod 3)$ becomes, written additively, $\rho(g_1) + \rho(g_2) \in \mathbb{Z}/2$: it says whether the two Frobenii are of the same kind.

**Theorem 7.1 (pair entropy).** $H(T_1, T_2) = \tfrac32 L = 2H(T)$.

*Proof.* The pair-type fibre sizes are the products of $\{1, 8, 3\}$ with itself: $1, 8, 3, 8, 64, 24, 3, 24, 9$. Equivalently, entropy is additive for independent components. $\square$

**Lemma 7.2 (fibres of the pair dial).** Each fibre of the dial has $72$ elements.
- *Same kind* (both rotations or both reflections): the type-pair counts are $(0,0) : 34$, $(0,2) : 9$, $(2,0) : 9$, $(2,2) : 9$, $(0,6) : 5$, $(6,0) : 5$, $(6,6) : 1$.
- *Opposite kinds*: the counts are $(0,0) : 30$, $(0,2) : 15$, $(2,0) : 15$, $(0,6) : 3$, $(6,0) : 3$, $(2,6) : 3$, $(6,2) : 3$.

*Proof.* Rotations have types $\{6:1, 0:5\}$ and reflections $\{2:3, 0:3\}$. In the same-kind fibre, $(0,0)$ arises $5\cdot 5 = 25$ times from two blank rotations and $3 \cdot 3 = 9$ times from two edge-axis reflections, for a total of $34 = 2 \cdot 17$. The other entries are similar products. $\square$

**Theorem 7.3 (pair channel).**
$$H(T_1, T_2 \mid N \bmod 3) = \tfrac{23}{9} + \tfrac98 L - \tfrac{35}{72}L_5 - \tfrac{17}{72} L_{17},$$
$$I_{\mathrm{pair}} = I(N \bmod 3;\ (T_1,T_2)) = \tfrac38 L + \tfrac{35}{72} L_5 + \tfrac{17}{72} L_{17} - \tfrac{23}{9} \approx 0.13262.$$
Moreover $0.07 < I_{\mathrm{pair}} < 0.15$, and $0 < I_{\mathrm{pair}} < I(p \bmod 3; T)$.

*Proof.* Apply (5.1) to the two fibres of Lemma 7.2, using $\log_2 72 = 3 + 2L$, $\log_2 34 = 1 + L_{17}$, $\log_2 30 = 1 + L + L_5$, $\log_2 15 = L + L_5$, and $\log_2 9 = 2L$. Collect terms and subtract from Theorem 7.1. The enclosure uses $4 < L_{17} < \tfrac{41}{10}$, which follows from $17^{10} < 2^{41}$, together with the bounds on $L$ and $L_5$. $\square$

The prime $17$ enters only through the coincidence count $34 = 25 + 9$. The pair channel shows genuine structure, but it is diluted: the product dial $N \bmod 3$ forgets which of the two primes has which residue.

---

## 8. Information versus prediction

Entropy measures uncertainty. A forecaster, however, is scored by the **Bayes error**, the least possible fraction of misclassified Frobenius classes over all predictors $f(\text{dial})$. Within a dial fibre, the best predictor guesses the majority type. So the minimal number of errors is
$$\mathrm{err}(k) = \sum_{c}\big(|S_c| - \max_t |\{x \in S_c : T(x) = t\}|\big).$$

**Theorem 8.1 (no dial).** Every constant guess of $T$ is wrong on at least $4$ of the $12$ elements of $D_6$. The guess $T = 0$ attains this.

**Theorem 8.2 (the conductor-3 dial gives no predictive gain).** For every function $f: \mathbb{Z}/2 \to \mathbb{Z}_{\ge 0}$, the predictor $f(\rho(g))$ errs on at least $4$ of the $12$ elements.

*Proof.* The rotation fibre $\{6:1, 0:5\}$ forces at least $1$ error, and the reflection fibre $\{2:3, 0:3\}$ forces at least $3$. Any guess outside $\{0,2,6\}$ is only worse, and the finitely many relevant guesses can be checked directly. $\square$

So $p \bmod 3$ carries $0.364$ bits about $T$, yet leaves the error rate at $1/3$. *Information and predictability do not coincide.* The reason is that the Bayes error depends only on the majority in each fibre, and the majority is $0$ in both fibres and in the unconditioned distribution. The rotation character only redistributes the minority mass: it moves type $6$ entirely into one fibre and type $2$ entirely into the other.

**Theorem 8.3 (non-abelian obstruction).** For every homomorphism $\varphi$ of $D_6$ into an abelian group and every function $f$ on the target, the predictor $f(\varphi(g))$ errs on at least one element of $D_6$. The error rate is therefore at least $1/12$.

*Proof.* By Proposition 3.8, $\varphi(r_2) = \varphi([r_1, s_0]) = 1 = \varphi(r_0)$. So $f(\varphi(r_0)) = f(\varphi(r_2))$, but $T(r_0) = 6 \ne 0 = T(r_2)$. $\square$

**Theorem 8.4 (the floor is attained by $p \bmod 24$).** The predictor "$T = 2$ if $\pi(g) = (1, 0)$, else $T = 0$" errs on exactly one element, namely $r_0$. Arithmetically: predict $T(p) = 2$ for $p \equiv 17, 23 \pmod{24}$ and $T(p) = 0$ otherwise. This is wrong exactly on the primes with $T(p) = 6$, which have density $1/12$.

| dial | information (bits) | minimal error |
|---|---|---|
| none | $0$ | $4/12$ |
| $p \bmod 3$ | $0.3637$ | $4/12$ |
| $p \bmod 24$ (abelian ceiling) | $0.9591$ | $1/12$ |
| full Frobenius | $1.1887$ | $0$ |

---

## 9. Algorithms

**Algorithm A (exact channel values from a permutation group).** *Input:* a finite group $G$ given as permutations of $\{0,\dots,n-1\}$, a read-out $T$ (here, fixed-point count), and a dial $k$. *Steps:* (1) for each $g \in G$ compute $T(g)$ and $k(g)$; (2) bucket the elements by $k$; (3) in each bucket, tally the $T$-values and apply (5.1); (4) combine with weights $|S_c|/|G|$ to get $H(T\mid k)$, and subtract from $H(T)$. The cost is $O(|G|\cdot n)$ time and $O(|G|)$ memory. For the pair channel the same routine runs on $G \times G$.

**Algorithm B (Bayes error of a dial).** Bucket as in Algorithm A and sum, over buckets, the bucket size minus its largest $T$-tally. The cost is $O(|G|)$.

**Algorithm C (prime-level types).** For a prime $p \ge 5$, let $d = \gcd(p-1, 6)$. Then $T(p) = d$ if $2^{(p-1)/d} \equiv 1 \pmod p$, and $T(p) = 0$ otherwise. This is Euler's criterion in the cyclic group $\mathbb{F}_p^\times$, combined with Theorem 4.1. The cost is $O(\log p)$ multiplications modulo $p$.

---

## 10. Numerical comparison

| quantity | exact closed form | exact value | experiment | primes $\le 2\cdot 10^5$ |
|---|---|---|---|---|
| $\Pr[T=0]$ | $2/3$ | $0.6667$ | $66\%$ | $0.6676$ |
| $\Pr[T=2]$ | $1/4$ | $0.2500$ | $25\%$ | $0.2499$ |
| $\Pr[T=6]$ | $1/12$ | $0.0833$ | $8\%$ | $0.0825$ |
| $H(T)$ | $\tfrac34 L$ | $1.1887$ | $1.1835$ | $1.1861$ |
| $I(p \bmod 3; T)$ | $\tfrac14L + \tfrac5{12}L_5 - 1$ | $0.3637$ | $0.3630$ | $0.3628$ |
| $I(p \bmod 24; T)$ | $\tfrac12 L + \tfrac16$ | $0.9591$ | — | — |
| $I_{\mathrm{pair}}$ | $\tfrac38L+\tfrac{35}{72}L_5+\tfrac{17}{72}L_{17}-\tfrac{23}9$ | $0.1326$ | $0.1321$ | — |

Among the $17{,}982$ primes $5 \le p \le 200{,}000$, the congruence law of Theorem 4.6 holds without exception, as it must. The experimental dependence of $T$ on $p \bmod 3$ was reported with a $z$-score of about $+1921$ against a shuffled null. This matches the size of the exact value $0.3637$ bits.

---

## 11. Discussion

The dihedral group $D_6$ is the first non-abelian Galois group in the family $x^n - 2$ for which the splitting-type channel has three distinct types. The channel framework holds up fully here: every measured quantity is the Chebotarev shadow of an exact $D_6$ quantity. Two structural phenomena emerge that do not arise in the abelian setting.

*The abelian ceiling* (Theorem 5.6) is a general data-processing inequality. Any dial factoring through an abelian quotient is dominated by the abelianisation. Through Kronecker–Weber, it gives a precise information-theoretic form of the principle that congruences see only the abelian part of Frobenius. For $x^6 - 2$, the residue $\tfrac14\log_2 3 - \tfrac16$ bits is the price of non-commutativity. It is concentrated entirely on the kernel coset $\{r_0, r_2, r_4\}$, where "$2$ is a sixth power modulo $p$" cannot be decided by congruences.

*The divergence of information and prediction* (Theorems 8.1–8.4) warns against reading mutual information as predictive power. The two failures have a common source and one additional twist. The $1/12$ floor comes from the commutator $r_2 = [r_1, s_0]$, which glues together the identity (six roots) and the rotations $r_2, r_4$ (no roots) under every abelian map. The zero gain of $p \bmod 3$ comes from entropy responding to the whole distribution, while the Bayes error responds only to majorities.

*Scope.* The equidistribution of Frobenius is used as a hypothesis. The group-side values are exact. The prime-level root law holds for every prime. The only finite case checks involved are enumerations over $12$ or $144$ group elements. The structural statements (fixed-point law for all even $n$, cyclic root law, refinement monotonicity, abelian ceiling) are proved in full generality.

---

## 12. Future work

**Frobenius-group defect law for $x^\ell - 2$.** For an odd prime $\ell$, the Galois group of $x^\ell - 2$ is the affine group $\mathrm{AGL}(1, \ell)$ of maps $x \mapsto ax + b$ on $\mathbb{F}_\ell$. The identity fixes $\ell$ roots, the $\ell - 1$ nontrivial translations fix none, and every map with $a \ne 1$ fixes exactly one. The abelianisation is $a \in \mathbb{F}_\ell^\times$, and only the fibre $a = 1$ is ambiguous. This suggests the defect law
$$H(T \mid G^{ab}) = \frac{h(1/\ell)}{\ell - 1}, \qquad h(x) = -x\log_2 x - (1-x)\log_2(1-x).$$
Under this law the abelian ceiling captures a fraction of $H(T)$ tending to $1$ as $\ell \to \infty$. By contrast, for $D_6$ the fraction is only about $0.807$.

**General $x^n - a$.** The fixed-point law proved here holds for all even $n$. A uniform treatment of the channels of $x^n - a$, whose Galois groups are subgroups of the holomorph $\mathbb{Z}/n \rtimes (\mathbb{Z}/n)^\times$, together with their abelian ceilings would place $D_6$ inside a family.

**Effective Chebotarev.** Replacing the equidistribution hypothesis by an effective Chebotarev bound would convert the exact group-side values into explicit error bars for finite prime ranges, matching the empirical deviations of Section 10.

**Beyond fixed points.** The full cycle type of Frobenius (the factorisation pattern of $x^6 - 2$ modulo $p$) is a finer read-out. Its abelian ceiling and non-abelian residue are open to the same analysis.
