# The D5 Dial Is Measured: Exact Information Content of Residues About Dihedral Splitting Types

**Aristotle**

*2026-09-29*

---

## Abstract

For a quintic number field $K$ whose Galois closure has group $D_5$, the splitting type $T(p)$ of an unramified prime $p$ is one of $1^5$, $5$ or $1\cdot 2^2$. A large empirical study measured the mutual information between the residue of $p$ modulo the conductor $m^\ast = 320$ and the type, obtaining $I(p \bmod 320;\,T) = 1.0054$ bits ($z = +338$), with $H(T) = 1.3517$ and within-class entropy $0.3463$; the analogous semiprime channel $I(N \bmod 320;\,(T(p),T(q)))$ also measured $1.0054$. We prove that, in the Chebotarev fibre-product model, both quantities equal **exactly one bit**. The key ingredient is a general *fibre-product law*: when the joint law of $(p \bmod m, \mathrm{Frob}_p)$ is uniform on the fibre product of $(\mathbb{Z}/m)^\times$ and $G$ over a common quotient, and the residue character is balanced, the residue carries precisely the information that the quotient image $\sigma(\mathrm{Frob}_p)$ carries about $T$, computed on $G$ alone, independently of the conductor, the residue set and the fibre multiplicity. For $D_5$ we compute $H(T) = \tfrac15 + \tfrac12\log_2 5$, $H(T\mid \sigma) = \tfrac12\log_2 5 - \tfrac45$, and $I = 1$; we show that every abelian read-out of a $D_5$ Frobenius carries either $0$ or exactly $1$ bit; we prove that the semiprime type-pair channel also carries exactly $1$ bit although the pair has entropy $2H(T)\approx 2.72$; we extend the one-bit law to every odd dihedral group $D_n$; and we show it fails for $D_2$, where the dial reads $\tfrac32 - \tfrac34\log_2 3 \approx 0.311$ bit. The measured excess $0.0054$ is thereby identified as pure finite-sample bias. We give explicit numerical confirmation with the $D_5$ quintic $x^5 - 5x + 12$, whose quadratic resolvent field is $\mathbb{Q}(\sqrt{-10})$.

---

## 1. Introduction

The Chebotarev density theorem says that the Frobenius element of a prime in a Galois extension $K/\mathbb{Q}$ is equidistributed among the elements of the Galois group $G$. Dirichlet's theorem on primes in progressions is the special case of cyclotomic fields: the residue $p \bmod m$ is the Frobenius of $p$ in $\mathbb{Q}(\zeta_m)$, with group $(\mathbb{Z}/m)^\times$. A natural question sits between the two: *how much does the cheap, observable residue $p \bmod m$ reveal about the expensive, hidden Frobenius class of $p$ in $K$?*

Measured in Shannon bits, this is the mutual information $I(p \bmod m;\,T)$ where $T$ is any class function of Frobenius — typically the splitting type. The present paper completes the analysis of this "residue dial" for the group $D_5$ at the conductor $m^\ast = 320 = 2^6\cdot 5$, where an extensive experiment (the 448th in a series) recorded

| quantity | measured | exact (this paper) |
|---|---|---|
| $H(T)$ | $1.3517$ | $\tfrac15 + \tfrac12\log_2 5 \approx 1.36096$ |
| $H(T \mid p \bmod 320)$ | $0.3463$ | $\tfrac12\log_2 5 - \tfrac45 \approx 0.36096$ |
| $I(p \bmod 320;\,T)$ | $1.0054$ | $1$ |
| $I(N \bmod 320;\,(T(p),T(q)))$ | $1.0054$ | $1$ |

Our verdict: **the D5 dial is measured**, and it reads exactly one bit.

The paper is organized as follows. Section 2 fixes notation for entropy on finite uniform spaces. Section 3 proves the general structural lemmas: conditional uniformity, invisibility of balanced covers, and the information of deterministic read-outs. Section 4 proves the fibre-product law. Section 5 applies it to $D_5$, including quantization and the conductor $320$. Section 6 treats the semiprime channel. Section 7 treats general dihedral groups. Section 8 compares with the measurement and discusses bias. Section 9 gives algorithms and numerical evidence, and Section 10 lists open problems.

---

## 2. Entropy on finite uniform spaces

Throughout, a *sample space* is a finite set $S$ carrying the uniform probability measure, and a *random variable* is any function on $S$. All logarithms are to base $2$.

**Definition 2.1 (Entropy).** For a finite nonempty set $S$ and a function $g : S \to B$,
$$H_S(g) = -\sum_{b \in g(S)} \frac{|g^{-1}(b)|}{|S|}\log_2\frac{|g^{-1}(b)|}{|S|} = \log_2|S| - \frac{1}{|S|}\sum_{x \in S}\log_2\bigl|\{y\in S : g(y) = g(x)\}\bigr|,$$
with $H_\emptyset(g) = 0$.

**Definition 2.2 (Conditional entropy, mutual information).** For $g : S \to B$ and $k : S \to C$,
$$H_S(g \mid k) = \sum_{c \in k(S)} \frac{|k^{-1}(c)|}{|S|}\, H_{k^{-1}(c)}(g), \qquad I_S(g;\,k) = H_S(g) - H_S(g \mid k).$$

These are the usual Shannon quantities of the uniform law on $S$ pushed forward by $g$ and $k$.

---

## 3. Structural lemmas

**Lemma 3.1 (Averaging form).** $H_S(g \mid k) = \dfrac{1}{|S|}\sum_{x\in S} H_{\{y \in S:\,k(y)=k(x)\}}(g)$.

*Proof.* Group the sum by the value $c = k(x)$; each cell $k^{-1}(c)$ contributes $|k^{-1}(c)|$ identical terms. $\square$

**Lemma 3.2 (Entropy sees only shapes).** Let $S_1, S_2$ be nonempty and suppose the count vectors of $g$ are proportional: $|\{x\in S_1: g(x)=t\}|\cdot|S_2| = |\{x\in S_2 : g(x)=t\}|\cdot|S_1|$ for every $t$. Then $H_{S_1}(g) = H_{S_2}(g)$.

*Proof.* Proportionality forces the same support and the same normalized frequencies $|g^{-1}(t)|/|S_i|$, and entropy is a function of these frequencies. $\square$

**Lemma 3.3 (Conditional uniformity).** Let $R : S \to C$ and $c : C \to D$. Suppose that for every $x \in S$ and every $t$, the $g$-count vector on the fine cell $\{R = R(x)\}$ is proportional to that on the coarse cell $\{c\circ R = c(R(x))\}$. Then
$$H_S(g\mid R) = H_S(g\mid c\circ R) \quad\text{and}\quad I_S(g;\,R) = I_S(g;\,c\circ R).$$

*Proof.* By Lemma 3.1 both conditional entropies are averages over $x\in S$ of cell entropies; by Lemma 3.2 the fine and coarse cells containing $x$ have the same entropy. $\square$

**Lemma 3.4 (Balanced covers are invisible).** Let $\pi : S \to U$ map into a finite set $U$ with every fibre over $U$ of the same size $K > 0$. Then for all $f$ and $h$ on $U$,
$$H_S(f\circ\pi) = H_U(f),\quad H_S(f\circ\pi \mid h\circ\pi) = H_U(f\mid h),\quad I_S(f\circ\pi;\,h\circ\pi) = I_U(f;\,h).$$

*Proof.* Every count on $S$ of an event pulled back from $U$ is exactly $K$ times the corresponding count on $U$, and $|S| = K|U|$. Frequencies are therefore unchanged; for the conditional version apply the unconditional one to each cell, which is again a balanced $K$-to-one cover of the corresponding cell in $U$. $\square$

**Lemma 3.5 (Constant read-outs).** $H_S(g \mid \text{const}) = H_S(g)$, hence $I_S(g;\,\text{const}) = 0$.

**Lemma 3.6 (Deterministic read-outs).** If $k = \varphi\circ g$ on $S$, then $I_S(g;\,k) = H_S(k)$.

*Proof.* Inside a cell $\{k = c\}$, the $g$-fibres are the global $g$-fibres (since $g$ determines $k$). Writing both $H_S(g)$ and $H_S(g\mid k)$ in the second form of Definition 2.1, the sums over $\log_2|g\text{-fibre}|$ cancel, leaving $\log_2|S| - \frac{1}{|S|}\sum_c |k^{-1}(c)|\log_2|k^{-1}(c)| = H_S(k)$. $\square$

---

## 4. The fibre-product law

**The model.** Let $K/\mathbb{Q}$ be Galois with group $G$ and let $m$ be a conductor. For primes $p \nmid m\cdot\mathrm{disc}(K)$, Chebotarev's theorem in the compositum $K(\zeta_m)$ shows that the pair $(p \bmod m, \mathrm{Frob}_p)$ is equidistributed on the fibre product
$$\mathcal{F} = \{(a, g) \in (\mathbb{Z}/m)^\times \times G \;:\; \chi(a) = \sigma(g)\},$$
where $Q = \mathrm{Gal}\bigl((K\cap\mathbb{Q}(\zeta_m))/\mathbb{Q}\bigr)$ and $\sigma: G\to Q$, $\chi:(\mathbb{Z}/m)^\times \to Q$ are the restriction maps. We abstract this: $U$ is an arbitrary finite set of residues, $\chi : U \to Q$ and $\sigma : G \to Q$ are arbitrary maps, and $\mathcal{F}(U,\chi,\sigma) = \{(a,g)\in U\times G : \chi(a)=\sigma(g)\}$ carries the uniform law.

**Definition 4.1 (Balanced residue read-out).** The model is *balanced with multiplicity $K$* if $|\{a \in U : \chi(a) = \sigma(g)\}| = K > 0$ for every $g \in G$.

(For a surjective character of a finite abelian group, every fibre has the same size; this is the Dirichlet balance of the abelian quotient.)

**Theorem 4.2 (Fibre-product law: the residue only speaks through the common quotient).** Let $T : G \to B$ be any function. In a balanced model,
$$I_{\mathcal{F}}\bigl(T(g);\ a\bigr) \;=\; I_G\bigl(T;\ \sigma\bigr),$$
where the right-hand side is computed on $G$ with its uniform law. In particular the value is independent of the conductor $m$, the residue set $U$, and the multiplicity $K$.

*Proof.* Three steps.

*Step 1 (the residue is conditionally uniform over its quotient class).* Fix $(a,g)\in\mathcal{F}$. The fine cell $\{(a',h)\in\mathcal F : a' = a\}$ is in bijection with $\{h\in G : \sigma(h) = \chi(a)\}$. The coarse cell $\{(a',h)\in\mathcal F: \chi(a') = \chi(a)\}$ is the product $\{a' \in U : \chi(a')=\chi(a)\}\times\{h : \sigma(h)=\chi(a)\}$, whose first factor has size $K$ by balance. So every $T$-count on the coarse cell is exactly $K$ times the corresponding count on the fine cell. Lemma 3.3 gives $I_{\mathcal F}(T(g);\,a) = I_{\mathcal F}(T(g);\,\chi(a))$.

*Step 2 (agreement on the support).* On $\mathcal{F}$, $\chi(a) = \sigma(g)$ identically, so $I_{\mathcal F}(T(g);\,\chi(a)) = I_{\mathcal F}(T(g);\,\sigma(g))$.

*Step 3 (forgetting the residue).* The projection $(a,g)\mapsto g$ from $\mathcal F$ to $G$ has fibre $\{a : \chi(a) = \sigma(g)\}$, of size $K$ for every $g$. By Lemma 3.4, $I_{\mathcal F}(T(g);\,\sigma(g)) = I_G(T;\,\sigma)$. $\square$

The theorem converts an arithmetic question about primes and residues into a finite computation on the Galois group.

---

## 5. The group $D_5$

Let $D_5 = \langle r, s \mid r^5 = s^2 = 1,\ srs^{-1} = r^{-1}\rangle$, the symmetry group of the regular pentagon, acting on the five roots of a $D_5$-quintic as on the pentagon's vertices.

**Definition 5.1 (Splitting type and sign).** For $g\in D_5$, let $T(g)$ be the cycle type of $g$ on the five roots: $1^5$ for the identity, $5$ for the four nontrivial rotations, $1\cdot 2^2$ for the five reflections. The *sign* $\sigma : D_5 \to \mathbb{Z}/2$ sends rotations (including $1$) to $0$ and reflections to $1$.

**Proposition 5.2.** (a) The type is a faithful encoding of the order: $T(g)$ corresponds to $\mathrm{ord}(g) \in \{1, 5, 2\}$ respectively. (b) $\sigma$ is a homomorphism to $(\mathbb{Z}/2, +)$. (c) *The abelianization of $D_5$ is $\mathbb{Z}/2$*: every homomorphism $\varphi$ from $D_5$ to a commutative group satisfies $\varphi(g) = 1$ if $\sigma(g) = 0$ and $\varphi(g) = \varphi(s)$ if $\sigma(g)=1$.

*Proof.* (a), (b) are direct. For (c): $\varphi(r)^{-1} = \varphi(srs^{-1}) = \varphi(r)$ by commutativity, so $\varphi(r)^2 = 1$; with $\varphi(r)^5 = 1$ this gives $\varphi(r) = 1$. Hence $\varphi$ kills all rotations and is constant on the coset of reflections. $\square$

**Theorem 5.3 (Exact entropies of the $D_5$ type channel).** With the uniform law on $D_5$:
$$H(T) = \tfrac15 + \tfrac12\log_2 5 \approx 1.36096,\qquad H(\sigma) = 1,$$
$$I(T;\,\sigma) = 1,\qquad H(T\mid\sigma) = \tfrac12\log_2 5 - \tfrac45 \approx 0.36096 .$$

*Proof.* The type densities are $1/10$, $4/10$, $5/10$, giving $H(T) = \tfrac{1}{10}(1+\log_2 5) + \tfrac{4}{10}(\log_2 5 - 1) + \tfrac{5}{10} = \tfrac15 + \tfrac12\log_2 5$. The sign has five elements in each class, so $H(\sigma) = 1$. Since $\sigma = \psi\circ T$ with $\psi(1\cdot 2^2) = 1$ and $\psi = 0$ otherwise, Lemma 3.6 gives $I(T;\sigma) = H(\sigma) = 1$, and $H(T\mid\sigma) = H(T) - 1$. Directly: the reflection cell has entropy $0$, the rotation cell has law $(1/5, 4/5)$ and entropy $\log_2 5 - \tfrac85$, and averaging with weights $\tfrac12$ gives the stated value. $\square$

**Theorem 5.4 (Quantization of the abelian dial).** For every homomorphism $\varphi$ from $D_5$ to a commutative group, $I(T;\,\varphi) \in \{0, 1\}$.

*Proof.* By Proposition 5.2(c), $\varphi = \lambda\circ\sigma$ where $\lambda(0) = 1$ and $\lambda(1) = \varphi(s)$. If $\varphi(s) = 1$, then $\varphi$ is constant and $I = 0$ by Lemma 3.5. Otherwise $\lambda$ is injective, so $\varphi$ and $\sigma$ generate the same partition of $D_5$ and $I(T;\varphi) = I(T;\sigma) = 1$. $\square$

By contrast, non-homomorphic read-outs are not quantized: the indicator of the identity carries $\approx 0.469$ bit. But by the fibre-product law, only read-outs through an abelian quotient are accessible to residues.

**Theorem 5.5 (The $D_5$ dial at every conductor).** Let $U$ be a finite residue set with a map $\chi : U\to\mathbb{Z}/2$ taking each value exactly $K>0$ times. In the fibre-product model over the sign,
$$I_{\mathcal F(U,\chi,\sigma)}\bigl(T(g);\,a\bigr) = 1 .$$

*Proof.* Balance for $\sigma$ follows from balance of $\chi$; apply Theorem 4.2 and Theorem 5.3. $\square$

**The conductor $m^\ast = 320$.** Let $U_{320}$ be the $\varphi(320) = 128$ reduced residues modulo $320$, and let $\chi_{-10}$ be the quadratic character of $\mathbb{Q}(\sqrt{-10})$ (conductor $40$, dividing $320$), written additively: $\chi_{-10}(a) = 0$ exactly when $a \bmod 40 \in \{1, 7, 9, 11, 13, 19, 23, 37\}$.

**Lemma 5.6 (Dirichlet balance at $320$).** Each value of $\chi_{-10}$ is taken by exactly $64$ residues in $U_{320}$. The same holds for the quadratic character $\chi_5$ of $\mathbb{Q}(\sqrt5)$ ($\chi_5(a) = 0$ iff $a \equiv \pm1 \pmod 5$).

*Proof.* Finite enumeration of the $128$ residues. $\square$

**Corollary 5.7 (The D5 dial is measured: prime channel).** For a $D_5$ field whose quadratic subfield is $\mathbb{Q}(\sqrt{-10})$, in the Chebotarev model
$$I(p \bmod 320;\,T) = 1 \text{ bit}.$$
The same value holds with $\chi_5$ in place of $\chi_{-10}$, i.e. it does not depend on which quadratic subfield the $D_5$ field has.

The classical quintic $f(x) = x^5 - 5x + 12$ has discriminant $2^{12}\cdot 5^6$ and Galois group $D_5$; its type modulo $p$ is read off from the number of roots ($5$, $0$ or $1$). For all $33{,}857$ primes $7 \le p < 400{,}000$ one checks that $f$ has exactly one root modulo $p$ if and only if $\chi_{-10}(p) = 1$, consistent with $\mathbb{Q}(\sqrt{-10})$ being the quadratic subfield of the splitting field.

---

## 6. The semiprime channel

For a semiprime $N = pq$, the hidden variable is the type pair $(T(p), T(q))$, and the visible variable is $N \bmod m$. Because $\chi$ is multiplicative, $\chi(N) = \chi(p)\chi(q)$, i.e. additively $\chi(N) = \sigma(\mathrm{Frob}_p) + \sigma(\mathrm{Frob}_q)$. Given the two Frobenius elements, $N$ is uniform on the $\chi$-class $\sigma(p)+\sigma(q)$. So the model is the fibre product over $G\times G$ with quotient map $\sigma_2(g,h) = \sigma(g)+\sigma(h)$.

**Theorem 6.1 (Semiprime pair channel).** On $D_5\times D_5$ with the uniform law,
$$H(T\times T) = 2\bigl(\tfrac15 + \tfrac12\log_2 5\bigr) \approx 2.72,\quad H(\sigma_2) = 1,\quad I(T\times T;\,\sigma_2) = 1,$$
$$H(T\times T\mid\sigma_2) = \log_2 5 - \tfrac35 \approx 1.72 .$$
Consequently, for every balanced residue model, and in particular at $m^\ast = 320$ with $\chi_{-10}$,
$$I\bigl(N \bmod 320;\,(T(p),T(q))\bigr) = 1 = I(p \bmod 320;\,T).$$

*Proof.* Entropy is additive for independent coordinates. The parity $\sigma_2$ is a function of the type pair and is a fair coin (the sum mod $2$ of two independent fair coins is fair), so Lemma 3.6 gives $I = H(\sigma_2) = 1$. The residue statement follows from Theorem 4.2 applied to $G\times G$. $\square$

Thus the recorded coincidence $1.0054 = 1.0054$ is an exact identity of the underlying quantities. The single bit carried by $N \bmod m$ is the parity of reflections among the two Frobenius elements — which is the Kronecker symbol $\left(\frac{-40}{N}\right)$, already publicly computable from $N$. It says nothing about the individual types, and nothing about the factors.

---

## 7. Dihedral groups in general

Let $D_n$ ($n\ge 1$) be the dihedral group of order $2n$ with sign $\sigma$ (rotations $\mapsto 0$, reflections $\mapsto 1$).

**Lemma 7.1.** $\sigma$ takes each value exactly $n$ times, so $H(\sigma) = 1$.

**Theorem 7.2 (Odd dihedral one-bit law).** If $n$ is odd and $T(g) = \mathrm{ord}(g)$, then $I(T;\,\sigma) = 1$. Hence, for every balanced residue model over the sign, $I(p\bmod m;\,T) = 1$.

*Proof.* For odd $n$, every rotation has order dividing $n$, hence odd, while every reflection has order $2$. So $\sigma(g) = 1 \iff \mathrm{ord}(g) = 2$, i.e. $\sigma$ is a function of $T$. Lemma 3.6 and Lemma 7.1 give $I = H(\sigma) = 1$; Theorem 4.2 transfers it to residues. $\square$

(For odd $n$ the order also determines the sign when $T$ is the vertex cycle type, since reflections of an odd polygon have cycle type $1\cdot 2^{(n-1)/2}$ and rotations have all cycles of equal odd length.)

**Theorem 7.3 (Parity is essential: $D_2$).** For the Klein group $D_2$ with $T = $ order,
$$I(T;\,\sigma) = \tfrac32 - \tfrac34\log_2 3 \approx 0.311 < 1 .$$

*Proof.* The orders are $1, 2, 2, 2$, so $H(T) = H(\tfrac14,\tfrac34) = 2 - \tfrac34\log_2 3$. The rotation cell $\{1, r\}$ has orders $\{1,2\}$ and entropy $1$; the reflection cell has orders $\{2,2\}$ and entropy $0$. Hence $H(T\mid\sigma) = \tfrac12$ and $I = \tfrac32 - \tfrac34\log_2 3$. $\square$

Numerically, with $T$ the order, $I(T;\sigma)$ for $n = 4, 6, 8, 10, 12, 14$ equals $0.549, 0.655, 0.717, 0.758, 0.788, 0.811$; with $T$ the vertex cycle type it equals $0.656, 0.730, 0.774, 0.805, 0.827, 0.845$. Both sequences are below $1$ and increasing, which motivates Conjecture 10.2 below.

---

## 8. Measurement versus theory

Using $\tfrac{202}{87} < \log_2 5 < \tfrac{137}{59}$ (equivalently $2^{202} < 5^{87}$ and $5^{59} < 2^{137}$) one obtains the rigorous comparison:

**Proposition 8.1.** (i) The measured $H(T) = 1.3517$ lies below the exact value by an amount in $(0.0092, 0.0094)$. (ii) The measured within-class entropy $0.3463$ lies below the exact value by an amount in $(0.0146, 0.0148)$. (iii) The measured mutual information satisfies $1.0054 = 1.3517 - 0.3463$ and exceeds the exact value $1$ by $0.0054$, i.e. by $0.54\%$.

Both entropy estimates are *low*, as is characteristic of plug-in (maximum-likelihood) entropy estimators, and the conditional one is lower because it is estimated from more cells with fewer samples each. The excess in $I$ is therefore not uncertainty about the answer; it is a measurement of the sample.

**Plug-in bias.** For $M$ independent samples on a table with $\varphi(m)$ rows and $|T|$ columns, the classical first-order bias of the plug-in mutual information is $(\varphi(m)-1)(|T|-1)/(2M\ln 2)$. At $m=320$, $|T| = 3$, this is $127/(M\ln 2)$, which equals $0.0054$ at $M\approx 33{,}900$ — the number of primes below $400{,}000$. In the fibre-product model, however, the support is sparse: the $64$ residues with $\chi = 1$ each admit a single type, and the $64$ with $\chi=0$ admit two. Counting only occupied cells predicts a smaller bias, about $\bigl(64 - 2\bigr)/(2M\ln 2) \approx 0.0013$ at $M = 33{,}857$. A fresh count over the primes $7 \le p < 400{,}000$ with $f = x^5 - 5x+12$ gives plug-in values $H(T) = 1.3614$, $H(T\mid p\bmod 320) = 0.3604$, $I = 1.0010$, and for $300{,}000$ random products $N=pq$ of those primes, $I(N\bmod 320;\,\text{pair}) = 1.0011$ — consistent with the exact value $1$ plus the sparse-support bias. A shuffled-label baseline over the same primes has mean $\approx 0.0055$ (the generic bias) and standard deviation $\approx 0.0004$.

---

## 9. Algorithms

**Algorithm A (Exact dial on a finite group).** *Input:* a finite group $G$ (as a list of elements), a class function $T$, a quotient map $\sigma$. *Output:* $I_G(T;\sigma)$.
1. Tally counts $c(t,q) = |\{g : T(g)=t,\ \sigma(g)=q\}|$.
2. Compute $H(T)$ from the row sums and $H(T\mid\sigma) = \sum_q \frac{c(\cdot,q)}{|G|} H(c(\cdot,q))$.
3. Return $H(T) - H(T\mid\sigma)$.

Cost: $O(|G|)$. By Theorem 4.2, this computes the residue dial at every balanced conductor.

**Algorithm B (Fibre-product check).** Enumerate $\mathcal F = \{(a,g) : \chi(a) = \sigma(g)\}$ for the $\varphi(m)$ residues and compute $I(T(g);\,a)$ directly. Cost $O(\varphi(m)|G|)$; at $m=320$ and $G = D_5$ this is a $640$-point space and returns $1$ up to floating-point rounding, for both $\chi_{-10}$ and $\chi_5$; for the semiprime channel over $D_5\times D_5$ it is a $6{,}400$-point space and again returns $1$.

**Algorithm C (Empirical dial from primes).** For each prime $p \le X$ with $p \nmid 2\cdot3\cdot5$:
1. Compute $x^p \bmod (f, p)$ by repeated squaring in $\mathbb{F}_p[x]/(f)$ ($O(\log p)$ multiplications of degree-$4$ polynomials).
2. Compute $r(p) = \deg\gcd(f,\,x^p - x)$ over $\mathbb F_p$ — the number of roots.
3. Set $T(p) = 1^5, 5, 1\cdot2^2$ for $r = 5, 0, 1$ respectively (valid for a $D_5$ quintic).
4. Tabulate $(T(p), p\bmod m)$ and return the plug-in $\hat I$.

Cost: $O(\pi(X)\log X)$ field operations. The same table, with $N = pq$ for random pairs, gives the semiprime channel.

---

## 10. Discussion and open problems

The general lesson is that a residue sees a Galois group only through a quotient, that balanced covers are invisible to entropy, and that for $D_5$ the only nontrivial abelian quotient is a single fair coin determined by the type. This makes the "dial" a group invariant.

**Conjecture 10.1 (Abelianization dial law).** For every finite Galois group $G$ and class function $T$, the supremum over conductors of $I(p\bmod m;\,T)$ equals $I_G(T;\,\pi_{\mathrm{ab}})$, where $\pi_{\mathrm{ab}} : G\to G^{\mathrm{ab}}$. Theorem 4.2 reduces every conductor to one quotient; what remains is monotonicity under refinement of the quotient and the existence of a conductor realizing $G^{\mathrm{ab}}$ (class field theory).

**Conjecture 10.2 (Even dihedral deficit).** For $D_n$ with $n$ even and $T$ the vertex cycle type, $I < 1$, and the deficit tends to $0$ as $n\to\infty$. For even $n$ the half-turn $r^{n/2}$ shares the cycle type $2^{n/2}$ with the $n/2$ edge reflections, so the sign is ambiguous on a class of density $(n/2+1)/(2n)\to\tfrac14$, but within that class the reflections dominate as $n$ grows.

**Conjecture 10.3 (Semiprime pair collapse).** For every $G$ and every quotient $\sigma : G\to Q$ with $Q$ elementary abelian of exponent $2$ and $\sigma$ a function of $T$, the semiprime channel equals $H(\sigma(p)+\sigma(q))$; in particular it equals the prime channel whenever $\sigma$ is balanced.

**Conjecture 10.4 (Plug-in dial bias law).** For $M$ primes, $\mathbb E[\hat I] - I$ admits an expansion of order $1/M$ whose leading coefficient is determined by the number of occupied cells of the fibre product; the generic value $(\varphi(m)-1)(|T|-1)/(2M\ln 2)$ is an upper envelope attained when all cells are occupied.

The measurement is complete: the D5 dial reads exactly one bit, at $m^\ast = 320$ and at every other balanced conductor, for primes and for semiprimes alike.
