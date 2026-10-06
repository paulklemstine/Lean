# Full Pinning on the Abelian Ladder: Splitting-Type Information in Maximal Real Cyclotomic Fields and the Degree-Nine Rung $\mathbb{Q}(\zeta_{19})^+$

**Aristotle**

*October 2026*

---

## Abstract

Let $\ell$ be an odd prime and $K_\ell = \mathbb{Q}(\zeta_\ell)^+$ the maximal real subfield of the $\ell$-th cyclotomic field, a cyclic extension of $\mathbb{Q}$ of degree $m = (\ell-1)/2$. For a prime $p \neq \ell$, the splitting type of $p$ in $K_\ell$ is its residue degree $f(p)$, the order of $p^2$ in $(\mathbb{Z}/\ell)^\times$. Under the uniform (Chebotarev) model, in which $p \bmod \ell$ is uniformly distributed on $(\mathbb{Z}/\ell)^\times$, we prove the following. (i) The *splitting-type density law*: in any cyclic group of order $2m$, exactly $2\varphi(d)$ elements $g$ satisfy $\operatorname{ord}(g^2) = d$, for every $d \mid m$, so $\Pr[f = d] = \varphi(d)/m$. (ii) The *entropy law*: $H(f) = H_\varphi(m) := \sum_{d\mid m}\eta(\varphi(d)/m)$, where $\eta(x) = -x\log x$. (iii) *Full pinning*: $I(p \bmod \ell; f) = H(f)$, and already $p^2 \bmod \ell$ suffices, so the sign of the residue is pure thickening. At degree nine ($\ell = 19$) the densities are $1/9, 2/9, 6/9$, and $H(f) = \tfrac43\log 3 - \tfrac89\log 2$ exactly, which lies strictly between $1.22439$ and $1.22441$ bits. We then study readouts of Frobenius. On the rung of degree $m$, the fixed-root count of the defining polynomial determines the type **if and only if $m = 1$ or $m$ is prime**, whereas the factor-degree pattern always equals the type. For semiprimes $N = pq$, the *which-factor extra* $I(N;(T_p,T_q)) - I(N;\{T_p,T_q\})$ vanishes identically in every finite abelian group, and the split-count projection satisfies an exact law relating it to the "at least one factor splits" dial. Finally, the totient entropy is additive over coprime degrees, $H_\varphi(mn) = H_\varphi(m) + H_\varphi(n)$; consequently the $\ell = 37$ rung lies exactly one bit above the $\ell = 19$ rung. Numerical evidence over roughly $3 \times 10^5$ primes agrees with every prediction.

---

## 1. Introduction

How a rational prime decomposes in a number field is governed by its Frobenius element. In an abelian extension of conductor $\ell$, class field theory reduces the Frobenius to a residue class modulo $\ell$, and Chebotarev's density theorem (here Dirichlet's theorem suffices) makes that residue class uniformly distributed. The splitting behaviour of primes therefore becomes a question about a *random element of a finite cyclic group* and a *deterministic statistic* of it.

This paper puts that question in information-theoretic terms. We ask three things. How much uncertainty does the splitting type carry? How much of it is captured by the residue $p \bmod \ell$? And how much survives various coarser readouts: the number of roots of a defining polynomial modulo $p$, the residue of a product $N = pq$, or the number of split factors of $N$?

We call the family $\{K_\ell = \mathbb{Q}(\zeta_\ell)^+\}_{\ell \text{ odd prime}}$ the **abelian ladder**. Its rungs are cyclic fields of degree $m = (\ell - 1)/2$. A prior programme of measurement had checked "full pinning" ($I(\text{residue};\text{type}) = H(\text{type})$) on cyclic rungs of degree $2, 3, 4, 5, 6$ and $8$. The present work adds the ninth rung, $K_{19}$, with Galois group $C_9$. It is the first rung of odd composite degree, and its type lattice is the chain $1 \mid 3 \mid 9$. We prove every pre-stated prediction for it as a theorem of the uniform model, and we prove the general laws that make the ladder work on every rung.

**Summary of results.**

1. The Splitting-Type Density Law (Theorem 2.4) and the Entropy Law (Theorem 2.6), valid for every cyclic group of even order and hence on every rung.
2. Full pinning and structural thickening (Theorem 2.7).
3. The degree-nine rung: exact densities, exact entropy, and a certified decimal enclosure (Theorems 3.1–3.3).
4. The Fixed-Root Dichotomy (Theorem 4.4): root counting is lossless exactly on rungs of prime degree.
5. Semiprimes: the exact vanishing of the which-factor extra (Theorem 5.3) and the split-count law (Theorem 5.6).
6. Additivity of the totient entropy over coprime degrees (Theorem 6.1).

---

## 2. The splitting-type law on a cyclic group of even order

### 2.1 Information-theoretic conventions

All probability spaces are finite sets $\Omega$ with the uniform measure. A *statistic* is a function $X : \Omega \to A$ to a finite set. We write $P(X = a) = |X^{-1}(a)|/|\Omega|$ and use the Shannon entropy

$$H(X) = \sum_{a} \eta\big(P(X=a)\big), \qquad \eta(x) = -x \log x \ (\eta(0) = 0).$$

The joint statistic is $(X,Y)$, and the mutual information is $I(X;Y) = H(X) + H(Y) - H(X,Y)$. Logarithms are natural unless stated otherwise; dividing by $\log 2$ converts to bits.

**Definition 2.1 (determination, pinning).** $X$ *determines* $Y$ if $X(\omega) = X(\omega')$ implies $Y(\omega) = Y(\omega')$, i.e. $Y = F \circ X$ for some $F$. We say $X$ *pins* $Y$ if $I(X;Y) = H(Y)$.

**Lemma 2.2 (pinning criterion).** $X$ pins $Y$ if and only if $X$ determines $Y$. If $X$ does not determine $Y$, then $I(X;Y) < H(Y)$ strictly.

*Proof sketch.* $H(Y) - I(X;Y) = H(X,Y) - H(X) = H(Y \mid X) = \sum_a P(X=a)\, H(Y \mid X = a)$. Each term is nonnegative, and since every value $a$ of $X$ has positive probability, the sum vanishes iff $Y$ is constant on every fibre of $X$. $\square$

### 2.2 The model

Let $\ell$ be an odd prime, $\zeta_\ell = e^{2\pi i/\ell}$, and $K_\ell = \mathbb{Q}(\zeta_\ell + \zeta_\ell^{-1})$. Then $\operatorname{Gal}(\mathbb{Q}(\zeta_\ell)/\mathbb{Q}) \cong (\mathbb{Z}/\ell)^\times$, a cyclic group of order $\ell - 1 = 2m$. Complex conjugation corresponds to $-1$, so $\operatorname{Gal}(K_\ell/\mathbb{Q}) \cong (\mathbb{Z}/\ell)^\times/\{\pm 1\} \cong C_m$. For a prime $p \neq \ell$, the Frobenius of $p$ in $K_\ell$ is the image of $p$ in $C_m$, and the residue degree $f(p)$ is its order.

**Lemma 2.3 (the type is the order modulo $\pm 1$).** Let $F$ be a field, $u \in F^\times$ and $f \ge 0$. Then $(u^2)^f = 1$ if and only if $u^f = 1$ or $u^f = -1$. Consequently, the order of $u$ in $F^\times/\{\pm1\}$ equals the order of $u^2$ in $F^\times$, and
$$f(p) = \operatorname{ord}_{(\mathbb{Z}/\ell)^\times}(p^2).$$

*Proof.* $(u^2)^f = (u^f)^2$, and in a field $x^2 = 1$ iff $(x-1)(x+1) = 0$ iff $x = \pm 1$. $\square$

By Dirichlet's theorem the residues $p \bmod \ell$ are equidistributed on $(\mathbb{Z}/\ell)^\times$. The **uniform Chebotarev model** therefore takes $\Omega = G := (\mathbb{Z}/\ell)^\times$ with the uniform measure and the **type statistic** $T(g) = \operatorname{ord}(g^2)$. Everything in Sections 2–4 holds for an arbitrary cyclic group $G$ of order $2m$.

### 2.3 The density law

**Theorem 2.4 (Splitting-Type Density Law).** Let $G$ be a cyclic group of order $2m$ and let $d \mid m$. Then
$$\#\{g \in G : \operatorname{ord}(g^2) = d\} = 2\varphi(d).$$
Hence $P(T = d) = \varphi(d)/m$ for $d \mid m$, and $P(T = d) = 0$ for every other $d$.

*Proof sketch.* There are four steps.

1. *Two square roots of unity.* $\#\{g : g^2 = 1\} = \sum_{e \mid 2}\#\{g : \operatorname{ord} g = e\} = \varphi(1) + \varphi(2) = 2$. This uses the standard fact that a cyclic group whose order is divisible by $e$ has exactly $\varphi(e)$ elements of order $e$.
2. *Fibres of squaring are cosets.* For any $g_0$, the map $g \mapsto g_0^{-1}g$ is a bijection from $\{g : g^2 = g_0^2\}$ onto $\{g : g^2 = 1\}$. So every nonempty fibre of $g \mapsto g^2$ has exactly 2 elements.
3. *The squares are the $m$-torsion.* If $s^m = 1$, write $s = \gamma^k$ for a generator $\gamma$ of order $2m$. Then $2m \mid km$, so $k$ is even and $s = (\gamma^{k/2})^2$. Conversely $(g^2)^m = g^{2m} = 1$. In particular $\operatorname{ord}(g^2) \mid m$ always.
4. *Count.* Group the set $\{g : \operatorname{ord}(g^2) = d\}$ by the value $s = g^2$. The admissible $s$ are exactly the elements of order $d$. There are $\varphi(d)$ of them, each is a square by step 3 (since $d \mid m$), and each has a fibre of size 2 by step 2. The total is $2\varphi(d)$. $\square$

**Remark 2.5.** Summing over $d \mid m$ recovers $\sum_{d\mid m} 2\varphi(d) = 2m = |G|$, by Gauss's identity $\sum_{d\mid m}\varphi(d) = m$.

### 2.4 The entropy law and full pinning

**Theorem 2.6 (Ladder Entropy Law).** For a cyclic group of order $2m$,
$$H(T) = H_\varphi(m) := \sum_{d \mid m} \eta\!\left(\frac{\varphi(d)}{m}\right).$$
We call $H_\varphi(m)$ the **totient entropy** of $m$.

*Proof.* Substitute Theorem 2.4 into the definition of entropy. Values $d \nmid m$ contribute $\eta(0) = 0$. $\square$

**Theorem 2.7 (Full Pinning; Structural Thickening).** For any finite abelian group $G$,
$$I(g; T) = H(T) \qquad\text{and}\qquad I(g^2; T) = H(T).$$
In the cyclotomic model: $I(p \bmod \ell; f) = I(p^2 \bmod \ell; f) = H(f)$.

*Proof.* $T$ is a function of $g$, and indeed of $g^2$. Apply Lemma 2.2. $\square$

The second identity is the precise sense in which the thickening is *structural*. The residue $p \bmod \ell$ carries $\log_2(2m)$ bits, of which only the image in the Galois group $C_m = G/\{\pm1\}$ is relevant. The remaining sign bit is independent of the type, and is the information a residue carries beyond the type.

**Corollary 2.8 (Every rung).** For every odd prime $\ell$ and every $d \mid (\ell-1)/2$, the primes of residue degree $d$ in $\mathbb{Q}(\zeta_\ell)^+$ have density $\varphi(d)\big/\tfrac{\ell-1}{2}$, and the splitting type has entropy $H_\varphi\big(\tfrac{\ell-1}{2}\big)$ and is fully pinned by $p \bmod \ell$.

*Proof.* $|(\mathbb{Z}/\ell)^\times| = \ell - 1 = 2\cdot\frac{\ell-1}{2}$, and this group is cyclic. $\square$

---

## 3. The degree-nine rung $\mathbb{Q}(\zeta_{19})^+$

Here $\ell = 19$, $m = 9$, $\operatorname{Gal}(K_{19}/\mathbb{Q}) \cong C_9$, and $K_{19} = \mathbb{Q}(\alpha)$ with $\alpha = 2\cos(2\pi/19)$, whose minimal polynomial is
$$\Psi_{19}(x) = x^9 + x^8 - 8x^7 - 7x^6 + 21x^5 + 15x^4 - 20x^3 - 10x^2 + 5x + 1.$$
The divisors of $9$ are $1, 3, 9$, with $\varphi(1) = 1$, $\varphi(3) = 2$, $\varphi(9) = 6$.

**Theorem 3.1 (Degree-nine densities).**
$$P(f = 1) = \tfrac19, \qquad P(f = 3) = \tfrac29, \qquad P(f = 9) = \tfrac69.$$
Explicitly, $f = 1$ for $p \equiv \pm 1$, $f = 3$ for $p \equiv \pm 7, \pm 8$, and $f = 9$ for the remaining twelve classes modulo $19$.

*Proof.* Theorem 2.4 with $m = 9$. The explicit classes follow from $7^2 \equiv 11$ and $11^3 \equiv 1$, and $8^2 \equiv 7$ and $7^3 \equiv 1 \pmod{19}$. $\square$

**Theorem 3.2 (Exact entropy).**
$$H(f) = \tfrac43 \log 3 - \tfrac89 \log 2.$$

*Proof.* We have $\eta(1/9) = \tfrac29\log 3$, $\eta(2/9) = \tfrac29(2\log 3 - \log 2)$ and $\eta(6/9) = \tfrac23(\log 3 - \log 2)$. Summing gives $\big(\tfrac29 + \tfrac49 + \tfrac23\big)\log 3 - \big(\tfrac29 + \tfrac23\big)\log 2 = \tfrac43\log 3 - \tfrac89\log 2$. $\square$

**Theorem 3.3 (Certified decimal enclosure).**
$$1.22439 < \frac{H(f)}{\log 2} < 1.22441.$$

*Proof.* From the integer inequalities $2^{1054} < 3^{665}$ and $3^{306} < 2^{485}$, taking logarithms gives
$$\frac{1054}{665} < \log_2 3 < \frac{485}{306}.$$
Since $H(f)/\log 2 = \tfrac43 \log_2 3 - \tfrac89$, these bounds give $1.2243943\ldots$ from below and $1.2244008\ldots$ from above, which lie inside the stated window. $\square$

**Corollary 3.4 (Full pinning at degree nine).**
$$I(p \bmod 19; f) = I(p^2 \bmod 19; f) = \tfrac43\log 3 - \tfrac89 \log 2 \approx 1.2244\ \text{bits}.$$

---

## 4. Readouts of Frobenius: the fixed-root dichotomy

### 4.1 Torsor model

Let $K/\mathbb{Q}$ be cyclic of degree $m$, generated by a root of an irreducible polynomial $\Psi$ of degree $m$. Its $m$ roots form a principal homogeneous space (torsor) under $C = \operatorname{Gal}(K/\mathbb{Q})$. For a prime $p$ not dividing the discriminant of $\Psi$, Dedekind's theorem says that the factorisation of $\Psi \bmod p$ into irreducibles over $\mathbb{F}_p$ has factor degrees equal to the cycle lengths of the Frobenius $\operatorname{Frob}_p$ acting on the roots, and the number of roots in $\mathbb{F}_p$ equals its number of fixed points. Since $C$ is abelian and acts simply transitively, identifying the roots with $C$ turns $\operatorname{Frob}_p$ into a translation $x \mapsto hx$.

**Proposition 4.1 (Fixed points of a translation).** In a finite group $C$, the translation $x \mapsto hx$ has $|C|$ fixed points if $h = 1$ and none otherwise.

*Proof.* $hx = x \iff h = 1$, independently of $x$. $\square$

**Proposition 4.2 (Cycle lengths of a translation).** Every point of $C$ lies on a cycle of $x \mapsto hx$ of length exactly $\operatorname{ord}(h)$.

*Proof.* The $n$-fold iterate is $x \mapsto h^n x$, and $h^n x = x \iff h^n = 1$. So the minimal period is $\operatorname{ord}(h)$ at every point. $\square$

**Corollary 4.3 (The pattern is the type).** The factor-degree pattern of $\Psi \bmod p$ is $[o^{m/o}]$ with $o = \operatorname{ord}(\operatorname{Frob}_p) = f(p)$. For $K_{19}$ the only patterns are $[1^9]$, $[3,3,3]$ and $[9]$. The root count is $\mathrm{nr}(p) = m$ if $f(p) = 1$ and $0$ otherwise.

### 4.2 The dichotomy

In the model of Section 2, define the **fixed-root readout** $R(g) = [\,g^2 = 1\,] \in \{0,1\}$, i.e. "Frobenius fixes the roots" ($\mathrm{nr} = m$) versus not ($\mathrm{nr} = 0$). Then $T$ determines $R$, since $R = [T = 1]$, and $P(R = 1) = 1/m$ by step 1 of Theorem 2.4.

**Theorem 4.4 (Fixed-Root Dichotomy).** Let $G$ be cyclic of order $2m$. The fixed-root readout $R$ determines the type $T$ if and only if $m = 1$ or $m$ is prime.

*Proof.* ($\Leftarrow$) If $m = 1$, then $T \equiv 1$. If $m$ is prime, then $T \in \{1, m\}$ by step 3 of Theorem 2.4, and $T = 1 \iff R = 1$.

($\Rightarrow$) If $m > 1$ is composite, choose a divisor $1 < d < m$. By Theorem 2.4 both types $d$ and $m$ occur, since $2\varphi(d) > 0$ and $2\varphi(m) > 0$. Both have $R = 0$, so $R$ does not determine $T$. $\square$

**Corollary 4.5 (Strict loss on composite rungs).** If $m$ is neither $1$ nor prime, then
$$I(g; R) = I(T; R) = H(R) < H(T).$$

*Proof.* The equalities hold because $R$ is a function of $T$, which is a function of $g$ (Lemma 2.2). The strict inequality is Lemma 2.2 applied to $R$ and $T$, using Theorem 4.4 and the symmetry of mutual information. $\square$

**Corollary 4.6 (Degree nine).** At $\ell = 19$, the root count carries exactly
$$H(R) = \eta(1/9) + \eta(8/9) \approx 0.5033\ \text{bits},$$
strictly less than $H(T) \approx 1.2244$ bits. The types $3$ and $9$ both give $\mathrm{nr} = 0$.

So the observation that "the root count is lossy at degree nine" is correct but not special to nine. It holds at *every* composite degree $4, 6, 8, 9, 10, 12, \ldots$ and fails at every prime degree.

---

## 5. Semiprimes on the abelian ladder

Let $G$ be a finite group and let $(p, q)$ be uniform on $G \times G$, modelling the Frobenius classes of two independent primes. Put $N = pq$.

### 5.1 Symmetrisation is free

**Lemma 5.1 (Symmetry of mutual information).** $I(X;Y) = I(Y;X)$.

*Proof.* $H(X,Y) = H(Y,X)$, since the swap of coordinates is a bijection. $\square$

**Proposition 5.2 (Symmetrisation is free).** Let $\sigma : \Omega \to \Omega$ be an involution and $Y : \Omega \to \Gamma \times \Gamma$ a pair-valued statistic with $Y \circ \sigma = \operatorname{swap} \circ Y$. If $X \circ \sigma = X$, then
$$I\big(X; \{Y_1, Y_2\}\big) = I(X; Y),$$
where $\{Y_1, Y_2\}$ denotes the unordered pair.

*Proof sketch.* The cell of an unordered pair $\{s,t\}$ is the union of the ordered cells $(s,t)$ and $(t,s)$. These are interchanged by $\sigma$, which preserves every level set of $X$. Hence, for every $b$,
$$P\big(X = b,\ \{Y_1,Y_2\} = \{s,t\}\big) = c_{st}\, P\big(X = b,\ Y = (s,t)\big) \quad\text{and}\quad P\big(\{Y_1,Y_2\} = \{s,t\}\big) = c_{st}\, P\big(Y = (s,t)\big),$$
with $c_{st} = 1$ if $s = t$ and $2$ otherwise. The conditional law of $X$ given the unordered pair therefore equals its conditional law given either ordered pair. Equivalently $X$ is conditionally independent of $Y$ given $\{Y_1, Y_2\}$, and the two mutual informations coincide. $\square$

**Theorem 5.3 (The which-factor extra vanishes).** Let $G$ be a finite **abelian** group and $F : G \to B$ any type function. Then
$$I\big(N; (F(p), F(q))\big) - I\big(N; \{F(p), F(q)\}\big) = 0.$$

*Proof.* Apply Proposition 5.2 with $\sigma(p,q) = (q,p)$. Commutativity gives $N \circ \sigma = qp = pq = N$. $\square$

At degree nine, with $F = T$ on $(\mathbb{Z}/19)^\times$, the extra is exactly $0$. The measured value $0.00053$ bits is sampling noise. The common value, computed by exact enumeration of all $18^2$ residue pairs, is
$$I\big(N \bmod 19; \{T_p, T_q\}\big) = 0.52650\ \text{bits}.$$

### 5.2 Thickening for semiprimes

**Proposition 5.4 (The sign of $N$ is independent noise).** Write $(\mathbb{Z}/19)^\times \cong C_2 \times C_9$ and $g = (g_2, g_9)$. Let $Y$ be any statistic of $(p_9, q_9)$, for instance any function of the type pair. Then $I(N; Y) = I(N_9; Y)$.

*Proof.* $T(g)$ depends only on $g_9$, because squaring kills $C_2$ and is a bijection on $C_9$. Now $N = (p_2 q_2,\ p_9 q_9)$, and $N_2 = p_2 q_2$ is uniform on $C_2$ and independent of $(p_9, q_9)$. The chain rule then gives $I(N;Y) = I(N_9;Y) + I(N_2; Y \mid N_9) = I(N_9; Y)$. $\square$

So semiprime quantities computed modulo $19$ agree with those computed in the Galois group $C_9$, as the numerics confirm.

### 5.3 The split-count law

A prime splits completely in $K$ iff its Frobenius is trivial. Define the **OR-fork** $O = [\,p = 1 \text{ or } q = 1\,]$ and the **split count** $S = [p = 1] + [q = 1] \in \{0,1,2\}$. The **OR-dial** is $I_s(n) := I(N; O)$, where $n = |G|$.

**Lemma 5.5 (OR-dial closed form).** For $|G| = n \ge 2$,
$$I_s(n) = h\!\left(\tfrac{2n-1}{n^2}\right) - \tfrac1n\, h\!\left(\tfrac1n\right) - \tfrac{n-1}{n}\, h\!\left(\tfrac2n\right), \qquad h(x) = \eta(x) + \eta(1-x).$$

*Proof.* $P(O = 1) = 1 - (n-1)^2/n^2 = (2n-1)/n^2$. Given $N = 1$, which has probability $1/n$, exactly one of the $n$ pairs with $pq = 1$, namely $(1,1)$, has $O = 1$. Given $N = c \neq 1$, exactly two pairs, $(1,c)$ and $(c,1)$, have $O = 1$. Hence $H(O\mid N) = \tfrac1n h(\tfrac1n) + \tfrac{n-1}{n} h(\tfrac2n)$. $\square$

**Theorem 5.6 (Split-Count Law).** For any finite group of order $n \ge 2$,
$$I(N; S) = I_s(n) + \eta\!\left(\frac{1}{n^2}\right) + \eta\!\left(\frac{2(n-1)}{n^2}\right) - \eta\!\left(\frac{2n-1}{n^2}\right).$$
Moreover $I(N;S) > I_s(n)$ strictly.

*Proof.* $(N,S)$ determines $(N,O)$ because $O = [S \neq 0]$. Conversely $(N, O)$ determines $(N, S)$: if $O = 0$ then $S = 0$; if $O = 1$ then $S = 2$ when $N = 1$ and $S = 1$ otherwise. So $H(N,S) = H(N,O)$, and
$$I(N;S) - I(N;O) = H(S) - H(O).$$
The laws are $P(S{=}2) = 1/n^2$, $P(S{=}1) = 2(n-1)/n^2$, $P(S{=}0) = P(O{=}0) = (n-1)^2/n^2$, and $P(O{=}1) = (2n-1)/n^2$. This gives the formula. Strictness is the strict subadditivity of $\eta$ on positive arguments: $\eta(a+b) = a\log\frac1{a+b} + b\log\frac1{a+b} < \eta(a) + \eta(b)$ for $a, b > 0$. $\square$

**Corollary 5.7 (Degree nine).** For $G = C_9$, $I_s(9) \approx 0.00604$ bits and
$$I(N; S) = I_s(9) + \eta(1/81) + \eta(16/81) - \eta(17/81) \approx 0.07378\ \text{bits}.$$
By Proposition 5.4 the same value holds for $N \bmod 19$.

---

## 6. Additivity of the totient entropy

**Theorem 6.1 (Coprime additivity).** If $m, n \ge 1$ and $\gcd(m,n) = 1$, then
$$H_\varphi(mn) = H_\varphi(m) + H_\varphi(n).$$

*Proof sketch.* Because $m$ and $n$ are coprime, $(a,b) \mapsto ab$ is a bijection from $\operatorname{Div}(m) \times \operatorname{Div}(n)$ onto $\operatorname{Div}(mn)$. Multiplicativity of $\varphi$ gives $\varphi(ab)/(mn) = x_a y_b$ with $x_a = \varphi(a)/m$ and $y_b = \varphi(b)/n$. The identity $\eta(xy) = y\,\eta(x) + x\,\eta(y)$ and the normalisations $\sum_a x_a = \sum_b y_b = 1$ (Gauss's identity) then give
$$H_\varphi(mn) = \sum_{a,b}\big(y_b\,\eta(x_a) + x_a\,\eta(y_b)\big) = H_\varphi(m) + H_\varphi(n). \qquad\square$$

In field-theoretic terms, a cyclic field of degree $mn$ is the compositum of its subfields of degrees $m$ and $n$. In the uniform model its type is the least common multiple of two *independent* types, and the pair can be recovered from it. Additivity is the information-theoretic face of the multiplicativity of $\varphi$. Coprimality is necessary: $H_\varphi(9) \approx 1.2244 \neq 2H_\varphi(3) \approx 1.8366$ bits.

**Proposition 6.2 (Prime degree).** For a prime $p$, $H_\varphi(p) = \eta(1/p) + \eta((p-1)/p)$, the binary entropy of "splits versus inert".

**Corollary 6.3 (The $\ell = 37$ rung).** $\mathbb{Q}(\zeta_{37})^+$ has degree $18 = 2 \cdot 9$, and its splitting type has entropy
$$H_\varphi(18) = \log 2 + \tfrac43\log 3 - \tfrac89\log 2,$$
exactly one bit above the degree-nine rung.

---

## 7. Algorithms

**Algorithm A (type from residue).** Input: an odd prime $\ell$ and a prime $p \ne \ell$. Compute $r = p^2 \bmod \ell$. Find the least $f \ge 1$ with $r^f \equiv 1 \pmod \ell$, either by iterated multiplication ($O(m)$ multiplications) or by testing the divisors of $m$ against the prime factorisation of $m$ ($O(\log^2 m)$ modular exponentiations). By Lemma 2.3 and Theorem 2.7 this output equals the residue degree.

**Algorithm B (factor-degree pattern over $\mathbb{F}_p$).** Input: a squarefree $\Psi \in \mathbb{Z}[x]$ of degree $m$ and a prime $p$ not dividing its discriminant. Distinct-degree factorisation: for $k = 1, 2, \ldots$ compute $x^{p^k} \bmod (\Psi, p)$ by repeated $p$-th powering, take $g_k = \gcd(\Psi, x^{p^k} - x)$, record $\deg g_k / k$ factors of degree $k$, and divide $\Psi$ by $g_k$. Stop when $2k > \deg \Psi$, and record any remaining cofactor as a single irreducible factor. The cost is $O(m^3 \log p)$ field operations with schoolbook arithmetic. By Corollary 4.3 the output is $[f^{m/f}]$. The root count $\deg g_1$ is lossy on composite rungs (Theorem 4.4).

**Algorithm C (exact mutual information by enumeration).** For statistics $X, Y$ on a finite uniform space $\Omega$, tabulate the counts of $X$, of $Y$ and of $(X,Y)$, and return $H(X) + H(Y) - H(X,Y)$. This takes $O(|\Omega|)$ time with hashing. For semiprimes, $\Omega = G \times G$ has $(2m)^2$ points; at $\ell = 19$ that is 324 points.

---

## 8. Numerical evidence

The uniform model is an idealisation of the primes. We record its agreement with actual data.

* **Densities.** Over 295,946 unramified primes, the empirical frequencies of $f = 1, 3, 9$ in $K_{19}$ matched $1/9, 2/9, 6/9$ to within $2\times 10^{-4}$. The empirical type entropy matched $1.2244$ bits.
* **Per-class degeneracy.** Within every residue class modulo $19$ the type is constant (Theorem 2.7). A control residue taken modulo a number coprime to $19$ carries no information about the type.
* **Polynomial cross-check.** For 400 randomly chosen primes, the factor-degree pattern of $\Psi_{19} \bmod p$ was $[1^9]$, $[3,3,3]$ or $[9]$, in agreement with $f(p)$ in 400 of 400 cases. The root count could not separate $f = 3$ from $f = 9$, as Theorem 4.4 predicts.
* **Semiprimes.** The measured $I(N \bmod 19; \{T_p,T_q\}) = 0.5330$ bits is consistent with the exact model value $0.52650$ bits, given sampling bias. The which-factor extra was measured at $0.00053$ bits, against an exact value of $0$. The split-count projection was measured at $0.0746$ bits, against an exact value of $0.07378$ bits.

**Remarks on earlier estimates.** Two numerical identifications made during the measurement campaign are corrected by the theory above. First, the "exact enumeration" value for the semiprime pair information is $0.52650$ bits, not $0.5302$. Second, the split-count projection ($0.07378$ bits) is *not* the OR-dial $I_s(9)$, which is $0.00604$ bits. The two differ by the explicit correction of Theorem 5.6. A further pitfall was the cross-check itself: a Frobenius of order $3$ fixes *no* roots (Proposition 4.1), so a root-count check cannot distinguish types $3$ and $9$, and factor patterns are required. Finally, encoding an unordered pair of types by a single integer such as $3\min + \max$ can collide. Any such encoding must be injective on the actual type values, or else it silently merges cells and biases mutual-information estimates.

---

## 9. Discussion

The theorems explain *why* full pinning holds on every rung of the abelian ladder, not merely that it has held on the rungs measured so far (degrees $2, 3, 4, 5, 6, 8, 9$). Once the uniform model is granted, everything reduces to the arithmetic of a cyclic group of even order: squaring is two-to-one, its image is the $m$-torsion, and there are exactly $\varphi(d)$ elements of each order $d$. The information-theoretic statements are then sharp. The residue carries all the information about the type. The sign is pure thickening. Readouts lose information exactly when they fail to determine the type, and Theorem 4.4 characterises arithmetically when the most natural readout, root counting, fails.

The semiprime results show a second structural principle. In an abelian group, the product $N = pq$ is blind to order, so "which factor" is never recoverable. The split count and the OR-fork differ only by a deterministic recoding given $N$, so their information difference is a closed-form entropy correction.

## 10. Future work

1. **Beyond $\mathbb{Q}(\zeta_\ell)^+$.** Extend the density and pinning laws to every cyclic field of conductor $c$, where the Galois group is a quotient of $(\mathbb{Z}/c)^\times$ by a subgroup that need not be $\{\pm1\}$, and to general abelian fields, where the type is the order in a quotient of a non-cyclic group.
2. **Non-abelian rungs.** For $S_3$ and other non-abelian Galois groups, Frobenius is a conjugacy class that no congruence condition determines. Quantify the gap $H(T) - I(p \bmod c; T)$.
3. **Semiprime thickening in general.** Prove the analogue of Proposition 5.4 for all $\ell$, and compute $I(N; \{T_p, T_q\})$ in closed form as a function of the divisor lattice of $m$.
4. **Totient entropy asymptotics.** Study the growth of $H_\varphi(m)$, which by Theorem 6.1 is additive over coprime prime-power factors and so behaves like an additive arithmetic function.
5. **Effective rates.** Replace the uniform model by effective Chebotarev bounds, so that the empirical agreement in Section 8 is quantified by explicit error terms.

---

## Appendix: degree-nine reference values

| quantity | exact | bits |
|---|---|---|
| $P(f=1), P(f=3), P(f=9)$ | $1/9,\ 2/9,\ 6/9$ | — |
| $H(f) = I(p \bmod 19; f)$ | $\tfrac43\log 3 - \tfrac89\log 2$ | $1.224394\ldots$ |
| root-count information | $\eta(1/9)+\eta(8/9)$ | $0.503258\ldots$ |
| semiprime pair information | enumeration over $18^2$ pairs | $0.526502\ldots$ |
| which-factor extra | $0$ | $0$ |
| OR-dial $I_s(9)$ | Lemma 5.5 | $0.006036\ldots$ |
| split-count information | Theorem 5.6 | $0.073775\ldots$ |
| $H_\varphi(18) - H_\varphi(9)$ | $\log 2$ | $1$ |
