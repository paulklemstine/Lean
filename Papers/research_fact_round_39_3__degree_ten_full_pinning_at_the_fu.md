# Full Pinning at Degree Ten: Exact Type Channels of the Cyclotomic Field $\mathbb{Q}(\zeta_{11})$

**Aristotle**

*October 2026*

---

## Abstract

For a Galois number field $K/\mathbb{Q}$ and an unramified prime $p$, the *Frobenius type* records how $p$ splits in $K$. We study the information-theoretic channel from a residue observation (such as $p \bmod n$) to the Frobenius type, in the model where Frobenius classes are uniformly distributed (Chebotarev). For the full cyclotomic field $\mathbb{Q}(\zeta_{11})$, of degree ten with cyclic Galois group $C_{10} \cong (\mathbb{Z}/11)^\times$, we prove that the residue $p \bmod 11$ *fully pins* the type: the mutual information equals the type entropy,
$$I(p \bmod 11;\ T) = H(T) = \log_2 5 - \tfrac35 \approx 1.72193,$$
the type is certain given the residue, and the residue retains exactly $8/5$ bits given the type. These follow from a general *abelian full-pinning law* valid for every finite abelian Galois group, together with a closed form $H(T) = -\sum_{d\mid n} \frac{\varphi(d)}{n}\log_2\frac{\varphi(d)}{n}$ for every cyclic field. We prove that for every $n$ and every prime $p \nmid n$ the cyclotomic polynomial $\Phi_n$ factors over $\mathbb{F}_p$ into $\varphi(n)/t$ irreducible factors of degree $t = \operatorname{ord}_n(p)$, and that this is the cycle pattern of multiplication by $p$ on $(\mathbb{Z}/n)^\times$. We analyse the tower $\mathbb{Q} \subset \mathbb{Q}(\zeta_{11})^+ \subset \mathbb{Q}(\zeta_{11})$, showing that the real quintic subfield is also fully pinned with $H(T^+) = \log_2 5 - 8/5$ and that the tower contributes exactly one bit. For semiprimes $N = pq$ we obtain the exact channel $I(N \bmod 11;\ \{T(p),T(q)\}) = \log_2 5 + \frac{12}{25}\log_2 3 - \frac{47}{25} \approx 1.20271$, an exact attenuation of $\frac{32}{25} - \frac{12}{25}\log_2 3 \approx 0.519$ bits relative to a single prime, and we prove that the *which-factor wall* — the extra information in the ordered type pair — vanishes identically for every finite group whenever the residue is read through the abelianization. All decimal values are certified by exact integer power comparisons.

---

## 1. Introduction

The splitting of rational primes in number fields is one of the oldest themes of algebraic number theory, and cyclotomic fields are its best-understood laboratory. In $\mathbb{Q}(\zeta_n)$ a prime $p \nmid n$ splits into $\varphi(n)/t$ primes of residue degree $t$, where $t$ is the multiplicative order of $p$ modulo $n$. Cyclotomic rings are also the arithmetic substrate of a large part of modern lattice-based cryptography, where the factorization of $\Phi_n$ modulo a prime governs the Chinese-remainder (number-theoretic transform) decomposition of the ring.

We adopt an information-theoretic viewpoint. Treat a random unramified prime as a random Frobenius class, uniformly distributed over the Galois group (the content of the Chebotarev density theorem, or for cyclotomic fields, Dirichlet's theorem). Then the residue of $p$ and its splitting type become two random variables on a finite probability space, and one can ask: *how many bits of the splitting type does the residue reveal?* Call this the **type channel**.

A sequence of computations for abelian fields of degrees $2, 3, 4, 5, 6, 8, 9$ — real subfields of cyclotomic fields and full cyclotomic fields — has found in every case that the residue reveals *all* of the type: the mutual information equals the type entropy. We call this **full pinning**. This paper treats the tenth rung, the full cyclotomic field $\mathbb{Q}(\zeta_{11})$, and does more: it proves full pinning for all abelian fields at once, derives the exact degree-ten constants, and settles several numerical questions raised by the experimental record.

### 1.1 Experimental background

The following predictions were made for $\mathbb{Q}(\zeta_{11})$ in advance and checked on data:

1. The type $T(p) = \operatorname{ord}_{11}(p)$ takes values in $\{1,2,5,10\}$ with densities $\{1/10, 1/10, 4/10, 4/10\}$; this was observed on $295{,}946$ unramified primes.
2. $I(p \bmod 11;\ T) = H(T) \approx 1.7219$ bits, with the type degenerate on each residue class.
3. On $400$ primes, the factor-degree pattern of $\Phi_{11} \bmod p$ was $[1^{10}]$, $[2^5]$, $[5,5]$ or $[10]$ according as $\operatorname{ord}_{11}(p) = 1, 2, 5, 10$.
4. For semiprimes, the channel $I(N \bmod 11;\ \text{type pair})$ was measured at $1.2002$, against an enumeration value $1.1999$ and an earlier closed-form prediction $1.2027$.

We prove items 1–3 exactly (item 3 for all primes and all conductors), and we resolve item 4: the exact law is $1.20271\ldots$, agreeing with the closed-form prediction to within $3\cdot 10^{-5}$ and strictly exceeding both other figures, which are therefore finite-sample estimates.

### 1.2 Summary of results

- **Theorem A (cyclic Chebotarev densities).** In a cyclic group of order $n$, exactly $\varphi(d)$ elements have order $d$ for each $d \mid n$; hence every cyclic field has type entropy $H(T) = -\sum_{d \mid n}\frac{\varphi(d)}{n}\log_2\frac{\varphi(d)}{n}$.
- **Theorem B (abelian full pinning).** For any finite abelian group, any injective residue readout $c$ and any type readout $T$: $I(c;T) = H(T)$, $H(T\mid c) = 0$, and $\log_2|A| - I(c;T) = H(c \mid T)$.
- **Theorem C (degree ten).** $I(p \bmod 11; T) = H(T) = \log_2 5 - \frac35$, $H(T \mid p \bmod 11) = 0$, $H(p \bmod 11 \mid T) = \frac85$.
- **Theorem D (factor patterns, all conductors).** $\Phi_n \bmod p$ has factor-degree multiset $[t^{\varphi(n)/t}]$, $t = \operatorname{ord}_n(p)$, equal to the cycle type of multiplication by $p$ on $(\mathbb{Z}/n)^\times$.
- **Theorem E (tower).** $H(T^+) = \log_2 5 - \frac85$, the real subfield is fully pinned, $H(T \mid T^+) = 1$, and $H(T) = H_{C_2} + H_{C_5}$.
- **Theorem F (semiprime channel).** $I(N \bmod 11; \{T(p),T(q)\}) = \log_2 5 + \frac{12}{25}\log_2 3 - \frac{47}{25}$.
- **Theorem G (which-factor wall).** For any finite group $G$ and any residue readout with $c(gh) = c(hg)$ — in particular any abelian $G$, or any $G$ read through its abelianization — ordered and unordered type pairs carry identical information about $c(gh)$.
- **Theorem H (attenuation and certified numerics).** $H(T) - I_{\mathrm{semi}} = \frac{32}{25} - \frac{12}{25}\log_2 3$, and $1.7219 < H(T) < 1.72193$, $1.20268 < I_{\mathrm{semi}} < 1.20272$.

---

## 2. Setting and definitions

### 2.1 Frobenius and splitting types

Let $K/\mathbb{Q}$ be a finite Galois extension with group $G$, and let $p$ be a prime unramified in $K$. The Frobenius elements of primes above $p$ form a conjugacy class $\operatorname{Frob}_p \subseteq G$. If $\operatorname{Frob}_p$ has order $t$ then $p$ factors in $K$ as a product of $|G|/t$ distinct primes, each of residue degree $t$.

**Definition 2.1 (Frobenius type).** The *Frobenius type* of $p$ in $K$ is $T(p) = $ the order of $\operatorname{Frob}_p$. More generally a *type readout* is any function $T : G \to \tau$ into a set of labels.

For the cyclotomic field $K = \mathbb{Q}(\zeta_n)$, the Galois group is canonically $(\mathbb{Z}/n)^\times$, via $\sigma_a : \zeta_n \mapsto \zeta_n^a$, and the Frobenius of a prime $p \nmid n$ is $\sigma_p$, i.e. the residue class $p \bmod n$. Thus $T(p) = \operatorname{ord}_n(p)$.

For the maximal real subfield $K^+ = \mathbb{Q}(\zeta_n + \zeta_n^{-1})$ the Galois group is $(\mathbb{Z}/n)^\times / \{\pm 1\}$, and the type $T^+(p)$ is the order of the image of $p$ in that quotient. For $n = 11$ the squaring map $g \mapsto g^2$ has kernel exactly $\{\pm 1\}$ — indeed $g^2 = h^2$ iff $g = \pm h$ — so it identifies the quotient with the subgroup of squares, and $T^+(p) = \operatorname{ord}_{11}(p^2)$.

### 2.2 The uniform-Frobenius model and information quantities

**Definition 2.2 (uniform model).** A *sample* is a finite set $S$ with the uniform probability measure. For the single-prime channel of an abelian field with group $A$, the sample is $S = A$: a random unramified prime is modelled by a uniformly random Frobenius element. For semiprimes $N = pq$ the sample is $A \times A$, the Frobenius classes of $p$ and $q$ being independent and uniform.

By the Chebotarev density theorem, this model describes the natural density of primes exactly.

**Definition 2.3 (entropy and mutual information).** For a readout $f : S \to \alpha$, the probability of a value $a$ is $P(f = a) = |\{w \in S : f(w) = a\}|/|S|$ and
$$H(f) = -\sum_{a} P(f=a)\log_2 P(f=a).$$
For two readouts $f,g$ we write $(f,g)$ for the joint readout $w \mapsto (f(w), g(w))$, and set
$$H(f \mid g) = H(f,g) - H(g), \qquad I(f;g) = H(f) + H(g) - H(f,g).$$

**Definition 2.4 (residue readout, full pinning).** A *residue readout* on a group $G$ is a function $c : G \to \kappa$; for cyclotomic fields we take $c(g) = $ the residue $p \bmod n$ itself, which is injective. The readout $c$ *fully pins* $T$ if $I(c;T) = H(T)$.

Since $I(c;T) = H(T) - H(T \mid c)$, full pinning is equivalent to *per-class degeneracy*: $H(T\mid c) = 0$, i.e. $T$ is constant on each fibre of $c$.

---

## 3. Cyclic fields: densities and closed-form type entropy

**Theorem 3.1 (Chebotarev densities of a cyclic field).** Let $G$ be a cyclic group of order $n$ and $d \mid n$. Then exactly $\varphi(d)$ elements of $G$ have order $d$. Consequently, in a cyclic field of degree $n$, the type $T = \operatorname{ord}$ takes the value $d$ with density $\varphi(d)/n$.

*Proof sketch.* $G$ has a unique subgroup of order $d$, which is cyclic, and the elements of order exactly $d$ are its generators, of which there are $\varphi(d)$. $\square$

**Corollary 3.2 (closed-form type entropy).** For a cyclic Galois group of order $n$,
$$H(T) = -\sum_{d \mid n} \frac{\varphi(d)}{n}\log_2\frac{\varphi(d)}{n}.$$

*Proof sketch.* Every element order divides $n$, so the values of $T$ lie in the divisor set of $n$; substitute the fibre sizes of Theorem 3.1 into Definition 2.3. $\square$

For $n = 10$, the divisors $1, 2, 5, 10$ have totients $1, 1, 4, 4$. Explicitly, in $(\mathbb{Z}/11)^\times$:

| type $d$ | elements of order $d$ | count $=\varphi(d)$ |
|---|---|---|
| $1$ | $1$ | $1$ |
| $2$ | $10$ | $1$ |
| $5$ | $3, 4, 5, 9$ | $4$ |
| $10$ | $2, 6, 7, 8$ | $4$ |

---

## 4. The abelian full-pinning law

**Theorem 4.1 (abelian full pinning).** Let $A$ be a finite abelian group, $c : A \to \kappa$ an injective residue readout, and $T : A \to \tau$ any type readout. Then, in the uniform model on $A$,
1. $I(c;T) = H(T)$ (the residue pins the type);
2. $H(T \mid c) = 0$ (per-class degeneracy);
3. $\log_2|A| - I(c;T) = H(c \mid T)$ (the loss equals the residue uncertainty given the type).

*Proof sketch.* The theorem is the abelian specialization of a general *coset law* for an arbitrary finite group $G$ with derived subgroup $G'$: if $c$ is a *coset readout*, i.e. $c(a) = c(b)$ iff $ab^{-1} \in G'$, then $c$ sees exactly the image of Frobenius in the abelianization $G/G'$, and one has $I(c;T) = H(T) - H(T\mid c)$, $\log_2|c(G)| - I(c;T) = H(c\mid T)$, and $I(c;T) = H(T)$ whenever $T$ is constant on $G'$-cosets. For abelian $A$ the derived subgroup is trivial, every injective readout is a coset readout, and every $T$ is constant on the (singleton) cosets. Concretely, $T$ factors through $c$, so the joint readout $(c,T)$ has the same fibres as $c$; thus $H(c,T) = H(c) = \log_2|A|$, which gives all three identities at once. $\square$

**Remark 4.2 (why abelianness is the right hypothesis).** In a non-abelian Galois group, a residue that is a class-field-theoretic invariant (a congruence condition) can only see the image of Frobenius in $G/G'$. Distinct conjugacy classes with different orders may share an abelianization image, in which case $H(T \mid c) > 0$ and pinning fails. Theorem 4.1 shows that in abelian fields there is no such obstruction: *every* splitting statistic is a function of the residue. This explains why the full-pinning prediction succeeded on every abelian rung examined — degrees $2$–$6$, $8$, $9$ and $10$, real subfields and full cyclotomic fields alike — with no exceptions.

---

## 5. Degree ten: exact constants

Let $A = (\mathbb{Z}/11)^\times$, let $c(g) = g$ (the residue $p \bmod 11$, represented in $\{1,\dots,10\}$) and $T(g) = \operatorname{ord}(g)$.

**Theorem 5.1 (type entropy at degree ten).** $H(T) = \log_2 5 - \tfrac35 \approx 1.72193$ bits.

*Proof.* By Theorem 3.1 the type distribution is $(1,1,4,4)/10$. Hence
$$H(T) = \tfrac{2}{10}\log_2 10 + \tfrac{8}{10}\log_2\tfrac{10}{4} = \log_2 10 - \tfrac{8}{10}\cdot 2 = 1 + \log_2 5 - \tfrac85 = \log_2 5 - \tfrac35. \qquad\square$$

**Theorem 5.2 (full pinning at degree ten).** In the uniform-Frobenius model for $\mathbb{Q}(\zeta_{11})$:
$$I(p \bmod 11;\ T) = H(T) = \log_2 5 - \tfrac35,\qquad H(T \mid p \bmod 11) = 0,\qquad H(p \bmod 11 \mid T) = \tfrac85.$$

*Proof.* The residue readout is injective, so Theorem 4.1 applies and gives the first two statements together with $\log_2 10 - I = H(c\mid T)$. Substituting Theorem 5.1, $H(c \mid T) = 1 + \log_2 5 - (\log_2 5 - \frac35) = \frac85$. $\square$

As an independent check, Corollary 3.2 for $n = 10$ reproduces the same value $\log_2 5 - \frac35$.

The interpretation of $8/5$ is direct: of the $\log_2 10 \approx 3.3219$ bits in the residue, $1.7219$ bits determine the splitting type, and the remaining $1.6$ bits distinguish residues sharing the same type (for example $3, 4, 5, 9$, all of type $5$). The type is a lossy summary of the residue; never the converse.

---

## 6. Factor patterns of cyclotomic polynomials, for every conductor

The experimental record checked factor patterns of $\Phi_{11}$ on $400$ primes. We replace this by a theorem for all primes and all conductors.

**Theorem 6.1 (factor-degree law).** Let $n \ge 1$ and $p$ a prime with $p \nmid n$, and let $t = \operatorname{ord}_n(p)$. Every monic irreducible factor of $\Phi_n$ in $\mathbb{F}_p[x]$ has degree $t$. Consequently the multiset of degrees of irreducible factors is
$$[\underbrace{t, t, \dots, t}_{\varphi(n)/t}].$$

*Proof sketch.* Since $p \nmid n$, $\Phi_n$ is separable over $\mathbb{F}_p$ and its roots are the primitive $n$-th roots of unity in $\overline{\mathbb{F}}_p$. A primitive $n$-th root $\eta$ lies in $\mathbb{F}_{p^k}$ iff $n \mid p^k - 1$, i.e. iff $t \mid k$; so $[\mathbb{F}_p(\eta):\mathbb{F}_p] = t$ and the minimal polynomial of every root has degree $t$. Since $\deg \Phi_n = \varphi(n)$ is the sum of the factor degrees, there are $\varphi(n)/t$ factors. $\square$

**Lemma 6.2 (group-side mirror).** Let $G$ be a finite group and $g \in G$. The permutation $x \mapsto gx$ of $G$ has all cycles of length $\operatorname{ord}(g)$, and the number of cycles is the index $[G : \langle g\rangle] = |G|/\operatorname{ord}(g)$.

*Proof sketch.* The cycles are the right cosets $\langle g\rangle x$, each of size $\operatorname{ord}(g)$. $\square$

**Theorem 6.3 (factor pattern $=$ orbit pattern).** For $p \nmid n$, the factor-degree multiset of $\Phi_n$ over $\mathbb{F}_p$ equals the cycle type of multiplication by the Frobenius class $p \bmod n$ on $(\mathbb{Z}/n)^\times$: $[\langle p\rangle$-index copies of the period of $x \mapsto px]$.

*Proof.* Combine Theorem 6.1 and Lemma 6.2 with $|(\mathbb{Z}/n)^\times| = \varphi(n)$. $\square$

**Corollary 6.4 (polynomial-level full pinning).** If $p, q \nmid n$ are primes with $p \equiv q \pmod n$, then $\Phi_n$ has the same factor-degree pattern over $\mathbb{F}_p$ and over $\mathbb{F}_q$.

**Corollary 6.5 (the four degree-ten patterns).** For every prime $p \ne 11$, the factor pattern of $\Phi_{11}$ over $\mathbb{F}_p$ is one of $[1^{10}]$, $[2^5]$, $[5,5]$, $[10]$, according as $\operatorname{ord}_{11}(p) = 1, 2, 5, 10$, and it is determined by $p \bmod 11$ alone as $[\operatorname{ord}(p)^{10/\operatorname{ord}(p)}]$. Witnesses: $p = 23 \equiv 1$ gives $[1^{10}]$; $p = 43 \equiv -1$ gives $[2^5]$; $p = 3$ (order $5$) gives $[5,5]$; $p = 2$ (a primitive root modulo $11$) gives $[10]$, so $\Phi_{11}$ is irreducible over $\mathbb{F}_2$.

**Remark 6.6 (a computational pitfall).** In the original 400-prime check, a first comparison reported $400/400$ mismatches while every pattern was in fact correct: the predicted pattern had been wrapped in one more layer of tuple than the computed one. A related pitfall is to index a lookup table by residue where it should be indexed by type. Theorem 6.3 makes the correct comparison canonical: both sides are multisets of positive integers summing to $\varphi(n)$.

---

## 7. The tower $\mathbb{Q} \subset \mathbb{Q}(\zeta_{11})^+ \subset \mathbb{Q}(\zeta_{11})$

### 7.1 Additivity of entropy for independent readouts

**Lemma 7.1.** Let $S_1, S_2$ be nonempty finite samples and $f : S_1 \to \alpha$, $g : S_2 \to \beta$. On the product sample $S_1 \times S_2$ the readout $(x,y) \mapsto (f(x), g(y))$ has entropy $H(f) + H(g)$.

*Proof sketch.* Fibres of the product readout are products of fibres, so probabilities multiply and $-\log_2$ turns products into sums. $\square$

### 7.2 The CRT splitting

$(\mathbb{Z}/11)^\times \cong C_{10} \cong C_2 \times C_5$, with $C_2 = \{\pm 1\} = \operatorname{Gal}(\mathbb{Q}(\zeta_{11})/\mathbb{Q}(\zeta_{11})^+)$ and $C_5$ the subgroup of squares $\{1, 3, 4, 5, 9\} = \operatorname{Gal}(\mathbb{Q}(\zeta_{11})/\mathbb{Q}(\sqrt{-11}))$. Under this decomposition the order of an element is the product of the orders of its components, and the product map is injective on pairs of coprime divisors $(d_2, d_5) \in \{1,2\}\times\{1,5\}$.

**Theorem 7.2 (CRT additivity at degree ten).** $H(T) = H_{C_2}(\operatorname{ord}) + H_{C_5}(\operatorname{ord})$, with $H_{C_2}(\operatorname{ord}) = 1$ and $H_{C_5}(\operatorname{ord}) = \log_2 5 - \frac85$.

*Proof sketch.* Transport the uniform measure along the isomorphism $C_{10} \to C_2 \times C_5$; $T$ becomes the product of the component orders, which by injectivity carries the same information as the pair of component orders; apply Lemma 7.1. The component values: in $C_2$ the orders $1,2$ are equiprobable (1 bit); in $C_5$ the orders $1,5$ have probabilities $1/5, 4/5$, giving $\frac15\log_2 5 + \frac45\log_2\frac54 = \log_2 5 - \frac85$. $\square$

### 7.3 The real quintic subfield and the tower bit

**Theorem 7.3 (real subfield).** In the degree-five real subfield $\mathbb{Q}(\zeta_{11})^+$, the type $T^+$ takes value $1$ on $\{\pm1\}$ and $5$ elsewhere, so
$$H(T^+) = \log_2 5 - \tfrac85 \approx 0.72193,$$
and the same residue $p \bmod 11$ fully pins it: $I(p \bmod 11; T^+) = H(T^+)$.

*Proof.* Distribution $(2, 8)/10$; full pinning by Theorem 4.1. $\square$

**Theorem 7.4 (the tower bit).** $H(T \mid T^+) = 1 = \log_2[\mathbb{Q}(\zeta_{11}) : \mathbb{Q}(\zeta_{11})^+]$. Equivalently, $H(T) = 1 + H(T^+)$, and $H(T^+) = H_{C_5}(\operatorname{ord})$.

*Proof.* The joint readout $(T^+, T)$ takes the values $(1,1), (1,2), (5,5), (5,10)$ with counts $1, 1, 4, 4$, so $H(T^+,T) = H(T) = \log_2 5 - \frac35$, and $H(T\mid T^+) = (\log_2 5 - \frac35) - (\log_2 5 - \frac85) = 1$. $\square$

---

## 8. The semiprime channel

Let $N = pq$ with $p, q \ne 11$ having independent uniform Frobenius classes $(g, h) \in A \times A$. Then $N \bmod 11 = gh$. Define the readouts
$$\nu(g,h) = gh, \qquad \pi(g,h) = \{T(g), T(h)\}\ (\text{unordered}),\qquad \omega(g,h) = (T(g), T(h))\ (\text{ordered}).$$

**Theorem 8.1 (semiprime channel, exact).**
$$I\big(N \bmod 11;\ \{T(p),T(q)\}\big) = \log_2 5 + \tfrac{12}{25}\log_2 3 - \tfrac{47}{25} \approx 1.2027101.$$

*Proof sketch.* All three entropies are computed from exact fibre counts on the $100$-element sample.

- $\nu$ is uniform on $10$ residues: $H(\nu) = \log_2 10 = 1 + \log_2 5$.
- $\pi$ takes the ten unordered values $\{1,1\},\{1,2\},\{1,5\},\{1,10\},\{2,2\},\{2,5\},\{2,10\},\{5,5\},\{5,10\},\{10,10\}$ with counts $1,2,8,8,1,8,8,16,32,16$, giving $H(\pi) = 2\log_2 5 - \frac{93}{50}$.
- The joint readout $(\nu,\pi)$ has $34$ nonempty cells with counts in $\{1,2,3,4,6,8\}$ (for instance, $\nu = 1$ splits as $\{1,1\}:1$, $\{2,2\}:1$, $\{5,5\}:4$, $\{10,10\}:4$; $\nu = 10$ splits as $\{1,2\}:2$, $\{5,10\}:8$; each quadratic-residue class $\nu \in \{3,4,5,9\}$ splits as $\{1,5\}:2$, $\{2,10\}:2$, $\{5,5\}:3$, $\{10,10\}:3$; each non-residue class $\nu \in\{2,6,7,8\}$ splits as $\{1,10\}:2$, $\{2,5\}:2$, $\{5,10\}:6$). Summing, $H(\nu,\pi) = 2\log_2 5 + \frac{51}{50} - \frac{12}{25}\log_2 3$.

Then $I = H(\nu) + H(\pi) - H(\nu,\pi) = \log_2 5 + \frac{12}{25}\log_2 3 - \frac{47}{25}$. $\square$

The terms in $\log_2 3$ arise solely from the cells of size $3$ and $6$, which occur because each square class $\nu$ of order $5$ is hit by exactly three ordered pairs of type $(5,5)$ and three of type $(10,10)$.

**Theorem 8.2 (ordered channel).** $H(\omega) = 2\log_2 5 - \frac65 = 2H(T)$, $H(\nu,\omega) = 2\log_2 5 + \frac{42}{25} - \frac{12}{25}\log_2 3$, and
$$I(N \bmod 11;\ (T(p),T(q))) = \log_2 5 + \tfrac{12}{25}\log_2 3 - \tfrac{47}{25}.$$
In particular the *which-factor wall* $I(\nu;\omega) - I(\nu;\pi)$ vanishes at degree ten.

This was obtained by a direct $56$-cell count; Section 9 proves it structurally for all groups.

---

## 9. The which-factor wall vanishes structurally

**Lemma 9.1 (entropy as average surprisal).** $H(f) = \frac{1}{|S|}\sum_{w \in S} -\log_2 P(f = f(w))$.

For a pair $o = (o_1, o_2)$ in a linearly ordered set, write $\operatorname{sym}(o) = (\min, \max)$; then $\operatorname{sym}(o) = \operatorname{sym}(o')$ iff $o' = o$ or $o' = o^{\mathrm{swap}}$.

**Lemma 9.2 (swap-symmetric pairs lose exactly the off-diagonal mass).** Let $\sigma$ be an involution of a finite sample $S$, let $Y$ be a readout with $Y\circ\sigma = Y$ and $O = (O_1, O_2)$ a pair readout with $O\circ\sigma = O^{\mathrm{swap}}$. Then
$$H(Y, O) = H\big(Y, \operatorname{sym} O\big) + P(O_1 \ne O_2).$$

*Proof sketch.* Use Lemma 9.1 pointwise. If $O_1(w) = O_2(w)$, the fibres of $(Y,O)$ and $(Y, \operatorname{sym}O)$ through $w$ coincide. If $O_1(w) \ne O_2(w)$, the fibre of $(Y,\operatorname{sym} O)$ through $w$ is the disjoint union of the $(Y,O)$-fibres through $w$ and through $\sigma(w)$, which $\sigma$ puts in bijection; so its probability is exactly twice as large and the surprisal drops by exactly one bit. Averaging gives $P(O_1 \ne O_2)$. $\square$

**Theorem 9.3 (which-factor wall, swap-invariant readouts).** Let $G$ be a group, $S \subseteq G$ finite, $c : G \to \kappa$ a readout with $c(gh) = c(hg)$ for all $g,h \in S$, and $T : G \to \tau$ a type readout into a linearly ordered set. On the sample $S\times S$,
$$I\big(c(gh);\ (T g, T h)\big) = I\big(c(gh);\ \{T g, T h\}\big).$$

*Proof.* Take $\sigma(g,h) = (h,g)$. Apply Lemma 9.2 once with $Y = c(gh)$ and once with $Y$ constant. Both corrections equal $P(Tg \ne Th)$, so in $I(Y;O) = H(Y) + H(O) - H(Y,O)$ they cancel. $\square$

**Corollary 9.4 (abelianization).** Let $G$ be any finite group with derived subgroup $G'$, and let $c$ be a coset readout of $G'$ ($c(a) = c(b)$ iff $ab^{-1} \in G'$). Then the which-factor wall vanishes for every type readout. In particular it vanishes for every finite abelian group and every readout whatsoever.

*Proof.* $(gh)(hg)^{-1} = ghg^{-1}h^{-1} = [g,h] \in G'$, so $c(gh) = c(hg)$; apply Theorem 9.3. $\square$

Applied to $A = (\mathbb{Z}/11)^\times$ this re-derives Theorem 8.2 without any cell count. Applied to the non-abelian groups $D_4$ (order $8$, symmetries of the square) and $A_4$ (order $12$, rotations of the tetrahedron) with their abelianization readouts, it explains why previously computed which-factor walls for these groups were exactly zero.

**Remark 9.5 (the reported wall of $0.0005$).** The figure $0.0005$ was the difference between two *estimates* ($1.2002$ measured and $1.1999$ enumerated) of the same quantity. By Theorem 9.3 the genuine which-factor wall is identically zero, and by Theorem 8.1 both estimates sit below the exact value.

---

## 10. Attenuation and certified numerics

**Theorem 10.1 (semiprime attenuation).** At degree ten the semiprime channel is strictly weaker than the single-prime channel:
$$H(T) - I\big(N \bmod 11; \{T(p),T(q)\}\big) = \tfrac{32}{25} - \tfrac{12}{25}\log_2 3 \approx 0.51922 > 0.$$

*Proof.* Subtract Theorem 8.1 from Theorem 5.1; positivity follows from $\log_2 3 < 8/3$. $\square$

**Lemma 10.2 (enclosures from integer powers).** For positive integers $a, m, n$: if $2^m < a^n$ then $m/n < \log_2 a$, and if $a^n < 2^m$ then $\log_2 a < m/n$. The exact integer inequalities
$$2^{23219} < 5^{10000},\quad 5^{100000} < 2^{232193},\quad 2^{158496} < 3^{100000},\quad 3^{100000} < 2^{158497}$$
give
$$2.3219 < \log_2 5 < 2.32193,\qquad 1.58496 < \log_2 3 < 1.58497.$$

*Proof sketch.* Apply the strictly increasing function $\log_2$ and divide by $n$. $\square$

**Theorem 10.3 (certified values).**
1. $1.7219 < I(p \bmod 11; T) = H(T) < 1.72193$.
2. $1.20268 < I_{\mathrm{semi}} < 1.20272$; hence $|I_{\mathrm{semi}} - 1.2027| < 3\cdot 10^{-5}$ and $I_{\mathrm{semi}} > 1.2002 > 1.1999$.

*Proof.* Insert Lemma 10.2 into the closed forms of Theorems 5.1 and 8.1; these are linear in $\log_2 5$ and $\log_2 3$ with explicit rational coefficients. $\square$

Thus the earlier closed-form prediction $1.2027$ *is* the law, and the enumeration value $1.1999$ is not.

---

## 11. Algorithms

**Algorithm 1 (exact type channel of a finite abelian group).** Input: a finite group given by its multiplication table, readouts $c$ and $T$. (i) Tabulate fibre counts of $c$, $T$ and $(c,T)$; (ii) compute entropies from counts. Cost $O(|G|)$ after the readouts are evaluated. For $(\mathbb{Z}/n)^\times$, computing all orders costs $O(\varphi(n)\cdot \lambda(n))$ naively, or $O(\varphi(n)\,\omega(\varphi(n))\log n)$ by testing $g^{\varphi(n)/r}$ for primes $r \mid \varphi(n)$. For the semiprime channel the sample is $G\times G$, cost $O(|G|^2)$.

**Algorithm 2 (factor pattern by distinct-degree factorization).** Input: prime $p \nmid n$. Set $f = \Phi_n \bmod p$, $h = x$. For $d = 1, 2, \dots$: replace $h \leftarrow h^p \bmod f$; $g = \gcd(f, h - x)$; record $\deg g / d$ factors of degree $d$; set $f \leftarrow f/g$; stop when $2d > \deg f$, recording the remaining $f$ as one factor if non-constant. This computes the pattern without reference to $\operatorname{ord}_n(p)$, giving an independent check of Theorem 6.1; its cost is $O(\varphi(n)^3\log p)$ field operations with schoolbook arithmetic. By Theorem 6.1 it can be replaced by a single order computation.

**Algorithm 3 (certified enclosure of $\log_2 a$).** To certify $m/n < \log_2 a < m'/n'$, compare the exact integers $2^m$ vs $a^n$ and $a^{n'}$ vs $2^{m'}$. With $n = 10^5$ this costs a few multiplications of integers with $\approx 2\cdot 10^5$ bits.

---

## 12. Discussion

**What the tenth rung establishes.** Every prediction formulated in advance for $\mathbb{Q}(\zeta_{11})$ is now a theorem in the uniform-Frobenius model: the densities $(1,1,4,4)/10$; full pinning at $\log_2 5 - \frac35$; per-class degeneracy; the residual $8/5$ bits. The factor-pattern check has been upgraded from $400$ primes to all primes and all conductors. The semiprime law has been corrected from the enumeration value $1.1999$ to the exact $1.20271$, matching the earlier closed form. The which-factor wall has been shown to vanish for structural reasons.

**Scope of full pinning.** Theorem 4.1 shows that full pinning is not a numerical coincidence accumulating rung by rung: for an abelian field, the residue modulo the conductor is the Frobenius, so every function of Frobenius — in particular every splitting statistic — is pinned. The interesting quantity is therefore not $I(c;T)$, which always equals $H(T)$, but the loss $H(c\mid T) = \log_2|A| - H(T)$, which measures how coarse the splitting type is relative to the full Frobenius. At degree ten it is $8/5$ bits; in the real quintic subfield it is $\log_2 5 - H(T^+) = 8/5$ bits as well.

**Cryptographic reading.** For cyclotomic rings $\mathbb{Z}[x]/\Phi_n$ used in lattice-based cryptography, Theorem 6.3 says the CRT decomposition of $\mathbb{F}_p[x]/\Phi_n$ is into $\varphi(n)/t$ copies of $\mathbb{F}_{p^t}$, determined entirely by $p \bmod n$. The semiprime results quantify a different phenomenon: a residue of a product $N = pq$ reveals strictly less about the splitting behaviour of the factors than a residue of a single prime does — at degree ten exactly $0.519$ bits less — and the attenuation is a consequence of multiplicative mixing of the two Frobenius classes.

**Limitations.** All statements concern the uniform-Frobenius model; their relation to finite prime counts is through the Chebotarev density theorem, and finite-sample estimates (such as $1.2002$ and $1.1999$) deviate from the law by sampling error. A further statistic reported in the experimental record (a projection value of $0.0586$ for an "$\mathrm{Is}(10)$" construction) is not treated here because its definition could not be reconstructed unambiguously.

---

## 13. Future work

1. **The 2-adic tower-gap law (conjecture).** For an odd prime $p$, $H(T) - H(T^+) = 2^{1 - v_2(p-1)}$ for $\mathbb{Q}(\zeta_p)$ and its maximal real subfield. The data give $1$ bit when $p \equiv 3 \pmod 4$ (as for $p = 11$, Theorem 7.4) and $1/2$ when $p \equiv 5 \pmod 8$. Writing $C_{p-1} = C_{2^k}\times C_{\mathrm{odd}}$, the odd part should cancel by CRT additivity, leaving $H(C_{2^k}) - H(C_{2^{k-1}}) = 2^{1-k}$.
2. **CRT additivity of cyclotomic type entropy (conjecture).** For coprime $m,n$, $H_{C_{mn}}(\operatorname{ord}) = H_{C_m}(\operatorname{ord}) + H_{C_n}(\operatorname{ord})$, with strict failure for non-coprime pairs (the data show losses of $0.75$ and $0.816$ bits for $(2,4)$ and $(3,9)$). Theorem 7.2 is the case $(m,n) = (2,5)$.
3. **Strict semiprime attenuation for every prime conductor $\ell \ge 5$ (conjecture).** $I(N \bmod \ell; \{T(p),T(q)\}) < H(T_\ell)$, with attenuation growing along primes for which $\ell - 1$ has many divisors. Theorem 10.1 is the first nontrivial calibration point, and Theorem 9.3 reduces the problem to the unordered pair.
4. **Real-subfield polynomial pinning (conjecture).** The minimal polynomial of $2\cos(2\pi/n)$ over $\mathbb{F}_p$ factors as $\varphi(n)/(2t^+)$ irreducibles of degree $t^+$, where $t^+$ is the order of $p$ in $(\mathbb{Z}/n)^\times/\{\pm1\}$ — the real-subfield analogue of Theorem 6.1.
5. **Non-abelian rungs.** Quantify the failure of pinning, $H(T\mid c) > 0$, for coset readouts of non-abelian Galois groups, where the residue sees only the abelianization.

---

## Appendix: numerical summary

| quantity | exact value | decimal |
|---|---|---|
| $H(T)$, $\mathbb{Q}(\zeta_{11})$ | $\log_2 5 - 3/5$ | $1.7219281$ |
| $I(p \bmod 11; T)$ | $\log_2 5 - 3/5$ | $1.7219281$ |
| $H(T \mid p \bmod 11)$ | $0$ | $0$ |
| $H(p \bmod 11 \mid T)$ | $8/5$ | $1.6$ |
| $H(T^+)$, $\mathbb{Q}(\zeta_{11})^+$ | $\log_2 5 - 8/5$ | $0.7219281$ |
| $H(T \mid T^+)$ | $1$ | $1$ |
| $H(N \bmod 11)$ | $1 + \log_2 5$ | $3.3219281$ |
| $H(\{T(p),T(q)\})$ | $2\log_2 5 - 93/50$ | $2.7838562$ |
| $H((T(p),T(q)))$ | $2\log_2 5 - 6/5$ | $3.4438562$ |
| $I(N \bmod 11; \{T(p),T(q)\})$ | $\log_2 5 + \frac{12}{25}\log_2 3 - \frac{47}{25}$ | $1.2027101$ |
| which-factor wall | $0$ | $0$ |
| attenuation | $\frac{32}{25} - \frac{12}{25}\log_2 3$ | $0.5192180$ |
| empirical $H(T)$, primes $< 4\cdot 10^6$ | — | $1.72204$ |
