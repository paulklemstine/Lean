# The Two Extremes of the Degree-Five Splitting-Type Channel

### Exact information laws for $S_5$ and $A_5$ quintics, an abelianization cap for arbitrary finite groups, and the absence of an almost-prime bonus

**Author:** Aristotle
**Date:** 2026-09-17

---

## Abstract

We study the splitting type of a prime in a quintic number field as an information channel, and determine exactly how many bits of that channel are visible to a congruence condition. Modelling the Frobenius distribution by the uniform (Chebotarev) measure on the Galois group, we define the *type read-out* $T$ to be the cycle type of the Frobenius element and a *dial* to be any homomorphism of the Galois group into an abelian group — the class of quantities a residue class can compute.

We compute the two extreme members of the transitive quintic row in closed form. For a quintic with Galois group $S_5$ the splitting entropy is
$$H(T) = \tfrac{7}{5} + \tfrac{17}{40}\log_2 3 + \tfrac{5}{24}\log_2 5 = 2.55734\ldots \text{ bits},$$
over a seven-state type alphabet — the largest splitting entropy in degrees $\le 5$. For a quintic with Galois group $A_5$ the odd types are absent and
$$H(T) = \tfrac{2}{15} + \tfrac{7}{20}\log_2 3 + \tfrac{5}{12}\log_2 5 = 1.65554\ldots \text{ bits}$$
over a four-state alphabet.

Against these entropies we prove two exact laws. At $S_5$: $I(\mathrm{sign};T) = 1$ exactly, and sharply — every homomorphism of $S_5$ into an abelian group transmits exactly $1$ bit if nontrivial and exactly $0$ if trivial, with no intermediate regime; the residual $H(T\mid \mathrm{sign}) = 1.55734\ldots$ bits is unreachable from any residue. At $A_5$: every multiplicative read-out into an abelian group is constant, so $I(d;T) = 0$ exactly, for every dial $d$ and every read-out $T$ — a parameter-free zero.

Both are instances of a general **abelianization cap**: for any finite group $G$, any homomorphism $\varphi : G \to M$ into an abelian group and any read-out $T$,
$$I(\varphi ; T) \le \log_2 |G^{\mathrm{ab}}|.$$
We upgrade the inequality to an exact formula: a homomorphic dial is uniform on its image, so $H(\varphi) = \log_2|\operatorname{im}\varphi|$, and whenever the read-out refines the dial, $I(\varphi ; T) = \log_2|\operatorname{im}\varphi|$. From the exact law we deduce that there is **no almost-prime bonus**: the $k$-fold product dial on $k$ independent Frobenius elements, read out by the tuple of types, transmits $\log_2|\operatorname{im}\varphi|$ bits for every $k \ge 1$. Semiprimes buy nothing.

Finally we show that none of this is a degree-five accident: $I(\mathrm{sign} ; \mathrm{cycleType}) = 1$ for the symmetric group on any finite set with at least two elements, and the sharp dichotomy together with the $A_n$ seal holds for every $n \ge 5$.

We accompany the theory with a numerical study of $x^5-x-1$ (group $S_5$, discriminant $2869 = 19\cdot 151$) and $x^5+20x+16$ (group $A_5$), including a discussion of the systematic upward bias of plug-in mutual-information estimates at large conductors and the permutation-reference discipline that removes it.

**Keywords:** splitting type, Frobenius, Chebotarev density, mutual information, abelianization, perfect group, quintic, class field theory, permutation reference.

---

## 1. Introduction

### 1.1 The question

Let $f \in \mathbb{Z}[x]$ be a monic irreducible quintic and $p$ a prime not dividing $\operatorname{disc}(f)$. Reducing $f$ modulo $p$ gives a squarefree polynomial over $\mathbb{F}_p$, and its factorisation into irreducibles has a **degree pattern** — a partition of $5$ — which we call the *splitting type* of $p$. Seven partitions of $5$ exist:
$$[5],\ [1,4],\ [2,3],\ [1,1,3],\ [1,2,2],\ [1,1,1,2],\ [1,1,1,1,1].$$

The splitting type is a cheap, computable, canonical statistic attached to each prime. The question we answer is how much of it a *congruence* can see:

> Given the residue $p \bmod m$ for a fixed modulus $m$, how many bits of information are thereby obtained about the splitting type of $p$?

The answer turns out to be independent of $m$, of the arithmetic of $f$ beyond its Galois group, and even of the number of primes one is allowed to combine. It is a pure group-theoretic invariant, and we compute it exactly at the two extremes of the quintic row.

### 1.2 The bridge: Frobenius and Chebotarev

Let $L$ be the splitting field of $f$ over $\mathbb{Q}$ and $G = \operatorname{Gal}(L/\mathbb{Q})$, viewed as a transitive subgroup of $S_5$ through its action on the five roots. For $p$ unramified, the Frobenius conjugacy class $\operatorname{Frob}_p \subseteq G$ is defined, and the classical **Dedekind factorisation theorem** states:

> The degree pattern of $f \bmod p$ equals the cycle type of $\operatorname{Frob}_p$ in its action on the roots.

The **Chebotarev density theorem** states that $\operatorname{Frob}_p$ is equidistributed: for each conjugacy class $C \subseteq G$, the density of primes with $\operatorname{Frob}_p = C$ is $|C|/|G|$.

Together these two theorems license the model we use throughout: replace the infinite set of primes by the finite probability space $(G, \text{uniform})$, and the splitting type by the cycle-type function on $G$.

### 1.3 What a residue can see

The second classical input is **class field theory**, which we use only in the following qualitative form. A residue condition $p \bmod m$ detects precisely the image of $\operatorname{Frob}_p$ in abelian quotients of $G$ (more precisely, in the Galois groups of abelian subextensions of $L$, all of which are cut out by congruences on $p$ by the Kronecker–Weber theorem). Hence:

> Any function of the Frobenius element visible to a congruence is a homomorphism of $G$ into an abelian group.

We call such a homomorphism a **dial**. The universal dial is the projection $G \to G^{\mathrm{ab}} = G/[G,G]$, through which every other one factors; $\log_2|G^{\mathrm{ab}}|$ is therefore the natural candidate for a ceiling, and Theorem D below shows that it is one.

The two extremes of the quintic row are then:

| Galois group | order | $G^{\mathrm{ab}}$ | # types | ceiling |
|---|---|---|---|---|
| $S_5$, e.g. $x^5-x-1$ | $120$ | $C_2$ | $7$ | $1$ bit |
| $A_5$, e.g. $x^5+20x+16$ | $60$ | trivial | $4$ | $0$ bits |

$S_5$ has the largest splitting entropy of any transitive group in degrees $\le 5$; $A_5$ is *perfect*, so its ceiling is zero. These are the two endpoints; everything in between (cyclic $C_5$, dihedral $D_5$, the Frobenius group $F_{20} = \mathrm{AGL}(1,5)$) has a nontrivial cyclic abelianization of order $5$, $2$ or $4$ respectively.

### 1.4 Results

- **Theorem A** (splitting entropies). Exact closed forms for $H(T)$ at $S_5$ and $A_5$, with certified decimal brackets, and the strict comparison $H_{A_5}(T) < H_{F_{20}}(T) < H_{S_5}(T)$.
- **Theorem B** (abelianization law at $S_5$, sharp form). $I(\varphi;T) \in \{0,1\}$ for every abelian dial $\varphi$ of $S_5$, equal to $1$ exactly when $\varphi$ is nontrivial; in particular $I(\mathrm{sign};T)=1$.
- **Theorem C** ($A_5$ seal). Every multiplicative read-out of $A_5$ into an abelian group is constant, whence $I(d;T)=0$ for every dial $d$ and every read-out $T$.
- **Theorem D** (abelianization cap). $I(\varphi;T) \le \log_2|G^{\mathrm{ab}}|$ for every finite group $G$, every abelian dial $\varphi$ and every read-out $T$; and the underlying maximum-entropy bound $H(g) \le \log_2 \#\{\text{values of } g\}$.
- **Theorem E** (exact law). $H(\varphi) = \log_2|\operatorname{im}\varphi|$ for a homomorphic dial, and $I(\varphi;T) = \log_2|\operatorname{im}\varphi|$ whenever $T$ refines $\varphi$.
- **Theorem F** (no almost-prime bonus). The $k$-fold product dial transmits $\log_2|\operatorname{im}\varphi|$ bits for every $k \ge 1$.
- **Theorem G** (the tower). $I(\mathrm{sign};\mathrm{cycleType}) = 1$ for $S_n$ in every degree $n \ge 2$; the sharp dichotomy and the $A_n$ seal hold for all $n \ge 5$.
- **Theorem H** (residual). $H(T \mid \mathrm{sign}) = \tfrac{2}{5}+\tfrac{17}{40}\log_2 3+\tfrac{5}{24}\log_2 5 = 1.55734\ldots > 0$ at $S_5$: the channel is strictly lossy in the reverse direction.

---

## 2. The counting-entropy framework

We work with a finite *box* $S$ (a finite set carrying the uniform measure) and *read-outs*, i.e. functions out of $S$ with values in some set with decidable equality.

**Definition 2.1 (entropy of a read-out).** For a finite box $S$ and a read-out $g : S \to B$, write $S_g(a) = \{x \in S : g(x) = g(a)\}$ for the fibre through $a$. The *counting entropy* is
$$H_S(g) \;=\; \log_2 |S| \;-\; \frac{1}{|S|}\sum_{a \in S} \log_2 |S_g(a)| .$$

This is exactly Shannon's $H = -\sum_b P(b)\log_2 P(b)$ for the pushforward distribution, written in a form in which each element of the box contributes once; grouping the sum by fibres recovers the familiar formula, since a fibre of size $c$ contributes $c \log_2 c$.

**Definition 2.2 (conditional entropy).** For read-outs $g : S \to B$ and $k : S \to C$,
$$H_S(g \mid k) \;=\; \sum_{c \in k(S)} \frac{|S_k(c)|}{|S|}\, H_{S_k(c)}(g),$$
the average entropy of $g$ over the strata cut out by $k$.

**Definition 2.3 (mutual information).** $I_S(g;k) = H_S(g) - H_S(g \mid k)$.

The framework satisfies the usual identities — the chain rule $H(g\mid k) = H(g,k) - H(k)$, symmetry $I(g;k) = I(k;g)$, non-negativity, and the caps $I(g;k) \le \min(H(g),H(k))$ — and in the present paper we need only the following three elementary facts, each an immediate consequence of the definitions.

**Lemma 2.4 (constant read-outs are silent).** If $g$ is constant on $S$ then $H_S(g) = 0$, and $I_S(g;k) = 0$ for every $k$.

*Proof.* Every fibre is all of $S$, so each summand $\log_2|S_g(a)| = \log_2|S|$ and $H_S(g) = 0$. Conditioning cannot make an entropy negative and the conditional terms are entropies of a constant read-out on sub-boxes, hence zero. $\square$

**Lemma 2.5 (refinement transmits everything).** If $k$ *refines* $g$, i.e. $k(x)=k(y) \Rightarrow g(x)=g(y)$ for $x,y \in S$, then $H_S(g\mid k)=0$ and therefore
$$I_S(g;k) = H_S(g).$$

*Proof.* On each stratum $\{k = c\}$ the read-out $g$ is constant, so every conditional term vanishes by Lemma 2.4. $\square$

**Lemma 2.6 (uniform fibres).** If every fibre of $g$ has the same cardinality $c > 0$, then $H_S(g) = \log_2(|S|/c)$.

*Proof.* Each of the $|S|$ summands in Definition 2.1 equals $\log_2 c$. $\square$

These three lemmas do all the work below; the arithmetic content is in identifying which read-outs refine which, and the group theory is in computing fibre sizes.

---

## 3. The two boxes and their splitting entropies

**Definition 3.1.** The *Chebotarev box* of an $S_5$-quintic is $S_5$ itself, all $120$ permutations of the five roots; the Chebotarev box of an $A_5$-quintic is the subgroup $A_5$ of $60$ even permutations. The *type read-out* $T(\sigma)$ is the cycle type of $\sigma$, written as a multiset of cycle lengths; by Dedekind's theorem it is the degree pattern of $f \bmod p$. The *sign dial* is $\operatorname{sgn} : \sigma \mapsto \pm 1$.

**Proposition 3.2 (the two type alphabets).** On the $S_5$ box exactly seven types occur, with class sizes
$$[1,1,1,1,1]: 1,\quad [1,1,1,2]: 10,\quad [1,2,2]: 15,\quad [1,1,3]: 20,\quad [2,3]: 20,\quad [1,4]: 30,\quad [5]: 24,$$
summing to $120$. On the $A_5$ box exactly four types occur,
$$[1,1,1,1,1]: 1,\quad [1,2,2]: 15,\quad [1,1,3]: 20,\quad [5]: 24,$$
summing to $60$; the three odd types $[1,1,1,2]$, $[2,3]$, $[1,4]$ never occur.

*Proof.* Direct enumeration of conjugacy classes of $S_5$; a cycle type is even iff it contains an even number of even parts, which excludes exactly the three listed types from $A_5$. (Note that the $5$-cycles form two conjugacy classes of size $12$ in $A_5$, but a single *type* class of size $24$: the type read-out is coarser than the conjugacy read-out in $A_5$, and this is the arithmetically correct choice, since $f \bmod p$ remembers only degrees.) $\square$

**Theorem A (splitting entropies).**
$$H_{S_5}(T) = \frac{7}{5} + \frac{17}{40}\log_2 3 + \frac{5}{24}\log_2 5, \qquad 2.5573 < H_{S_5}(T) < 2.5574,$$
$$H_{A_5}(T) = \frac{2}{15} + \frac{7}{20}\log_2 3 + \frac{5}{12}\log_2 5, \qquad 1.6555 < H_{A_5}(T) < 1.6556 .$$

*Proof sketch.* By Definition 2.1 and Proposition 3.2,
$$H_{S_5}(T) = \log_2 120 - \tfrac{1}{120}\bigl(1\log_2 1 + 10\log_2 10 + 15 \log_2 15 + 20\log_2 20 + 20\log_2 20 + 30 \log_2 30 + 24\log_2 24\bigr).$$
Expanding each $\log_2 n$ in the basis $\{1, \log_2 3, \log_2 5\}$ ($\log_2 120 = 3 + \log_2 3 + \log_2 5$, $\log_2 10 = 1 + \log_2 5$, $\log_2 15 = \log_2 3 + \log_2 5$, $\log_2 20 = 2 + \log_2 5$, $\log_2 30 = 1 + \log_2 3 + \log_2 5$, $\log_2 24 = 3 + \log_2 3$) and collecting terms gives the stated closed form; the $A_5$ computation is identical with $\log_2 60 = 2 + \log_2 3 + \log_2 5$. The decimal brackets follow from certified rational enclosures of the two logarithms, each obtained from an integer power inequality: $2^{1054} < 3^{665}$ and $3^{306} < 2^{485}$ give $\tfrac{1054}{665} < \log_2 3 < \tfrac{485}{306}$, and $2^{339} < 5^{146}$, $5^{643} < 2^{1493}$ give $\tfrac{339}{146} < \log_2 5 < \tfrac{1493}{643}$. Substituting these rational bounds into the closed forms and clearing denominators yields the brackets by a finite rational computation. $\square$

**Corollary 3.3 (the quintic ordering).** With $H_{F_{20}}(T) = \tfrac{11}{10} + \tfrac14 \log_2 5 = 1.68048\ldots$ for the Frobenius group of order $20$,
$$H_{A_5}(T) \;<\; H_{F_{20}}(T) \;<\; H_{S_5}(T).$$
The $S_5$ value is the largest splitting entropy occurring in degrees $\le 5$: the richest source in the family is exactly the one whose abelianization is smallest but nontrivial.

---

## 4. The abelianization law at $S_5$

The arithmetic content of the $S_5$ law is a single classical statement.

**Lemma 4.1 (the type determines the sign).** For permutations $\sigma,\tau$, if $\sigma$ and $\tau$ have the same cycle type then $\operatorname{sgn}\sigma = \operatorname{sgn}\tau$. Indeed $\operatorname{sgn}\sigma = (-1)^{\,n - (\text{number of cycles})}$ depends only on the multiset of cycle lengths.

Arithmetically: the parity of the splitting type of $p$ equals the quadratic character $\left(\frac{\operatorname{disc} f}{p}\right)$. For $f = x^5-x-1$ the discriminant is $\operatorname{disc}(f) = 2869 = 19 \cdot 151$, so the one visible bit is "is $2869$ a square modulo $p$?".

**Lemma 4.2 (the sign dial is balanced).** Each of the two sign fibres in the $S_5$ box has exactly $60$ elements, so by Lemma 2.6 $H_{S_5}(\operatorname{sgn}) = \log_2(120/60) = 1$.

**Theorem B (the sharp abelianization law at $S_5$).** Let $M$ be any abelian group and $\varphi : S_5 \to M$ a homomorphism. Then
$$I_{S_5}(\varphi ; T) = \begin{cases} 1, & \varphi \text{ nontrivial},\\ 0, & \varphi \text{ trivial}.\end{cases}$$
In particular $I_{S_5}(\operatorname{sgn} ; T) = 1$ exactly, and $I_{S_5}(\varphi;T) \le 1$ for every abelian dial. There is no intermediate regime.

*Proof sketch.* Three steps.

1. *Every abelian dial kills $A_5$.* Restrict $\varphi$ to $A_5$. Its kernel is normal in the simple group $A_5$, hence trivial or everything. If trivial, $\varphi$ embeds $A_5$ in an abelian group, forcing $A_5$ to be abelian — false, since the three-cycles $(0\,1\,2)$ and $(0\,1\,3)$ do not commute. Hence $\varphi|_{A_5} \equiv 1$.

2. *Hence $\varphi$ factors through the sign.* If $\operatorname{sgn}x = \operatorname{sgn}y$ then $xy^{-1}$ is even, so $\varphi(x)\varphi(y)^{-1} = \varphi(xy^{-1}) = 1$. Composing with Lemma 4.1, $\varphi$ is a function of the cycle type, so the type read-out refines the dial and Lemma 2.5 gives $I(\varphi;T) = H(\varphi)$.

3. *Compute $H(\varphi)$.* If $\varphi$ is trivial this is $0$ by Lemma 2.4. If $\varphi$ is nontrivial, pick $\tau$ with $\varphi(\tau) \ne 1$; by step 1, $\tau$ is odd. Then $\varphi(x) = \varphi(y)$ *iff* $\operatorname{sgn}x = \operatorname{sgn}y$: the "if" is step 2, and for the converse, if the signs differ then $xy^{-1}$ is odd, hence $xy^{-1}\tau^{-1}$ is even, hence $\varphi(x)\varphi(y)^{-1} = \varphi(\tau) \ne 1$. So the fibres of $\varphi$ are the two cosets of $A_5$, each of size $60$, and Lemma 2.6 gives $H(\varphi) = 1$. $\square$

**Theorem H (the residual).** $H_{S_5}(T \mid \operatorname{sgn}) = H_{S_5}(T) - I_{S_5}(T;\operatorname{sgn}) = \tfrac{2}{5} + \tfrac{17}{40}\log_2 3 + \tfrac{5}{24}\log_2 5 = 1.55734\ldots$, and in particular it is strictly positive: $1.5573 < H(T\mid \operatorname{sgn}) < 1.5574$.

*Proof.* Symmetry of mutual information gives $I(T;\operatorname{sgn}) = I(\operatorname{sgn};T) = 1$ by Theorem B; subtract from Theorem A. $\square$

The residual is the quantitative statement that the channel is *lossy in the reverse direction*: the splitting type determines the residue bit perfectly, but the residue bit determines almost nothing about the splitting type. Of the $2.55734\ldots$ bits carried by a random splitting type, congruences reach exactly $1$ and leave $1.55734\ldots$ locked inside the non-abelian part of the group.

---

## 5. The $A_5$ seal

**Theorem C ($A_5$ is perfect, and the channel is sealed).** Let $M$ be an abelian group and $d : A_5 \to M$ any *multiplicative read-out*, i.e. $d(xy) = d(x)d(y)$ for all $x,y \in A_5$. Then $d$ is constant. Consequently, for **every** read-out $T$ whatsoever (not merely the type),
$$I_{A_5}(d ; T) = 0 .$$

*Proof.* A multiplicative read-out is a homomorphism (taking $x=y=1$ gives $d(1)=1$ by cancellation). Its kernel is normal in $A_5$, which is simple, hence the kernel is trivial or all of $A_5$. Triviality would make $A_5$ isomorphic to a subgroup of an abelian group; but $(0\,1\,2)$ and $(0\,1\,3)$ do not commute. So the kernel is everything and $d \equiv 1$. Lemma 2.4 then gives $I(d;T) = 0$ for every $T$. $\square$

Two features of this statement deserve emphasis.

- **It is parameter-free.** No modulus is chosen, no conductor is optimised, no threshold is fitted. The zero is an identity, not an estimate.
- **It is universal in the read-out.** Theorem C does not merely say that the *cycle type* fails to inform the dial. It says that no function of the Frobenius element whatsoever — however exotic, however finely engineered — can be correlated with an abelian dial, because the dial itself is constant.

In the arithmetic model: for a quintic with Galois group $A_5$, such as $x^5+20x+16$ (whose discriminant is a perfect square, which is exactly the condition $G \subseteq A_5$), the splitting type of $p$ carries $1.65554\ldots$ bits of genuine randomness, and no congruence condition on $p$, of any modulus, can predict any of it.

**Corollary 5.1 (semiprime seal).** On the box $A_5 \times A_5$ of pairs of independent Frobenius elements, with read-out the pair of types and dial the product of the two sign characters, the mutual information is $0$. (Immediately, since the product dial is again constant.)

---

## 6. The general mechanism: a maximum-entropy bound and the abelianization cap

The two extremes are special cases of a general inequality that requires no arithmetic input whatsoever.

**Theorem D1 (maximum-entropy bound).** For any finite box $S$ and any read-out $g$ with $m = \#g(S)$ distinct values,
$$H_S(g) \le \log_2 m,$$
with equality iff all fibres have equal size.

*Proof sketch.* Write $N = |S|$ and let $f_1,\dots,f_m$ be the fibre sizes, $\sum f_v = N$. The claim is the log-sum inequality $\sum_v f_v \log_2 f_v \ge N \log_2(N/m)$. Apply $\ln x \le x-1$ to $x = \frac{N/m}{f_v}$ for each $v$: this gives $\ln\frac{N}{m} - \ln f_v \le \frac{N/m}{f_v} - 1$, hence $f_v\ln f_v \ge f_v \ln\frac{N}{m} - \frac{N}{m} + f_v$; summing over $v$ makes the correction terms cancel, $-m\cdot\frac{N}{m} + N = 0$, leaving the claim. Equality in $\ln x \le x-1$ holds iff $x=1$, i.e. $f_v = N/m$ for every $v$. $\square$

**Theorem D (abelianization cap).** Let $G$ be a finite group, $M$ an abelian group, $\varphi : G \to M$ a homomorphism and $T : G \to B$ any read-out. Then, on the box $G$ with counting measure,
$$I_G(\varphi ; T) \;\le\; \log_2 |G^{\mathrm{ab}}| .$$

*Proof sketch.* $I(\varphi;T) \le H(\varphi)$ (conditional entropy is non-negative), and $H(\varphi) \le \log_2 \#\varphi(G)$ by Theorem D1. Since $M$ is abelian, $\varphi$ kills the commutator subgroup and factors as $G \twoheadrightarrow G^{\mathrm{ab}} \to M$, so $\#\varphi(G) \le |G^{\mathrm{ab}}|$. $\square$

**Corollary 6.1.** $|A_5^{\mathrm{ab}}| = 1$, so Theorem D re-proves Theorem C in one line: the cap is $\log_2 1 = 0$, and mutual information is non-negative. Likewise $|S_5^{\mathrm{ab}}| = 2$ gives the one-bit ceiling of Theorem B, and $|F_{20}^{\mathrm{ab}}| = 4$ gives a two-bit ceiling for the Frobenius group.

The $F_{20}$ case shows that the cap is not always attained: for that group the actual transmitted information is $3/2$ bits, strictly below the ceiling $\log_2 4 = 2$, because two distinct dial classes are merged inside a single splitting type. The exact condition for equality is the subject of the next section.

---

## 7. The exact law and the absence of an almost-prime bonus

**Lemma 7.1 (fibres of a homomorphism are cosets).** For a homomorphism $\varphi : G \to M$ of a finite group and any $a \in G$, the fibre $\{x : \varphi(x)=\varphi(a)\}$ is in bijection with $\ker\varphi$ via $x \mapsto a^{-1}x$. Hence all fibres have the same cardinality $|\ker\varphi|$, and
$$\#\varphi(G)\cdot|\ker\varphi| = |G|.$$

**Theorem E1 (homomorphic dials are uniform).** For a homomorphism $\varphi$ of a finite group $G$,
$$H_G(\varphi) = \log_2 \#\varphi(G).$$
That is, a homomorphic dial *saturates* the maximum-entropy bound of Theorem D1: equidistribution of the Frobenius over $G$ pushes forward to equidistribution over the image of any character.

*Proof.* Lemma 7.1 says the fibres are uniform of size $|\ker\varphi|$; Lemma 2.6 gives $H = \log_2(|G|/|\ker\varphi|) = \log_2 \#\varphi(G)$. $\square$

**Theorem E (the exact law).** Let $\varphi : G \to M$ be a homomorphism of a finite group into an abelian group and let $T : G \to B$ be a read-out that *refines* $\varphi$, i.e.
$$T(x) = T(y) \;\Longrightarrow\; \varphi(x) = \varphi(y).$$
Then
$$I_G(\varphi ; T) = \log_2 \#\varphi(G) .$$

*Proof.* Refinement plus Lemma 2.5 gives $I(\varphi;T) = H(\varphi)$; Theorem E1 evaluates it. $\square$

The refinement hypothesis is exactly the arithmetic statement "the splitting type determines the character", which for $S_n$ is Lemma 4.1. Theorem E therefore contains both extremes: at $S_5$ with $\varphi = \operatorname{sgn}$, $\#\varphi(G) = 2$ and $I = 1$; at $A_5$, every dial has $\#\varphi(G) = 1$ and $I = 0$ (with the refinement hypothesis vacuous, since a constant dial is refined by anything).

### 7.1 The product channel

Let $k \ge 1$ and consider $k$ independent primes — an almost-prime $N = p_1\cdots p_k$ — with Frobenius elements $x_1,\dots,x_k$. Multiplicativity of Dirichlet characters means that what a residue class reads off $N$ is the *product* of the individual dial values.

**Definition 7.2 (product dial).** $\Phi_k : G^k \to M$, $\Phi_k(x_1,\dots,x_k) = \varphi(x_1)\cdots\varphi(x_k)$. This is a homomorphism because $M$ is abelian. The accompanying read-out is the *tuple of types* $T^{\otimes k}(x_1,\dots,x_k) = (T(x_1),\dots,T(x_k))$.

**Lemma 7.3.** For $k \ge 1$, $\operatorname{im}\Phi_k = \operatorname{im}\varphi$. ("$\supseteq$": take $x_1 = x$, the rest $1$. "$\subseteq$": the image of $\varphi$ is a subgroup, hence closed under products.)

**Theorem F (no almost-prime bonus).** If $T$ refines $\varphi$, then for every $k \ge 1$
$$I_{G^k}\bigl(\Phi_k \,;\, T^{\otimes k}\bigr) = \log_2 \#\varphi(G),$$
independently of $k$.

*Proof.* If $T^{\otimes k}(x) = T^{\otimes k}(y)$ then $T(x_i) = T(y_i)$ for each $i$, hence $\varphi(x_i) = \varphi(y_i)$, hence $\Phi_k(x) = \Phi_k(y)$: the tuple read-out refines the product dial. Apply Theorem E on the box $G^k$ and Lemma 7.3. $\square$

**Corollary 7.4 (degree five).** For an $S_5$-quintic and the product of quadratic characters, $I = 1$ bit for every $k \ge 1$: one prime, a semiprime, a product of a thousand primes — always exactly one bit. For an $A_5$-quintic the corresponding value is $0$ for every $k$.

**Remark 7.5 (what happens without refinement).** The refinement hypothesis is not decorative. For the Frobenius group $F_{20}$, whose abelianization is cyclic of order $4$ and whose type $[1,4]$ merges two dial classes, the $k$-prime channel can be computed exactly by convolving the per-coordinate conditional laws of the dial given the type; the answer is
$$I_k = 1 + 2^{-k} \qquad (k \ge 1),$$
i.e. $3/2,\ 5/4,\ 9/8,\ 17/16,\dots \to 1$. Combining primes there *destroys* information rather than creating it: each merged coordinate adds one more $\pm 1$ step of a random walk in the cyclic dial group. The flatness in $k$ of Theorem F is therefore a consequence of refinement, not a generic feature of product channels.

This settles in general a question that the numerical work raised at $k = 2$: there is no semiprime bonus, and the absence is structural rather than numerical. Intuitively, the product of $k$ quadratic characters is still a single quadratic character; the extra factorisation data of $N$ enters the read-out but cannot enlarge the *image* of the dial, which is where all the entropy lives.

---

## 8. The symmetric tower: the law in every degree

Nothing in Sections 4–5 is peculiar to degree five, and making that precise both generalises the results and explains them.

**Theorem G1 (one-bit law in every degree).** Let $\alpha$ be a finite set with $|\alpha| \ge 2$ and let $\operatorname{Perm}(\alpha)$ carry the uniform measure. Then the sign fibres are equinumerous (each of size $|\alpha|!/2$), so $H(\operatorname{sgn}) = 1$; the sign is a function of the cycle type; and therefore
$$I\bigl(\operatorname{sgn} ; \operatorname{cycleType}\bigr) = 1 .$$

*Proof.* Multiplication by a fixed transposition is a bijection between the even and odd classes, giving equal fibres and $H(\operatorname{sgn}) = 1$ by Lemma 2.6. The sign is determined by the cycle type (Lemma 4.1), so Lemma 2.5 applies. $\square$

**Theorem G2 (dichotomy and seal, $n \ge 5$).** If $|\alpha| \ge 5$, then $A_{|\alpha|}$ is perfect, hence:
(i) every homomorphism of $\operatorname{Perm}(\alpha)$ into an abelian group is trivial on the even permutations and factors through the sign;
(ii) for every such homomorphism $\varphi$, $I(\varphi;\operatorname{cycleType})$ equals $1$ if $\varphi$ is nontrivial and $0$ otherwise, so it is always $\le 1$;
(iii) on the box of even permutations, every abelian dial is constant, so $I(\varphi;T) = 0$ for every read-out $T$.

*Proof sketch.* Perfection of $A_n$ for $n\ge 5$ ($[A_n,A_n] = A_n$) replaces the simplicity argument of Theorem B step 1 and of Theorem C; the remaining steps are verbatim those of Theorem B. $\square$

Thus the degree-five statements are the first instances of a uniform law along the whole symmetric tower, and the only degree-dependent quantity in the entire picture is the splitting entropy $H(T)$ itself — the conjugacy-class histogram of $S_n$, an object of asymptotic combinatorics governed by the partition function.

---

## 9. Arithmetic realisation and numerical study

### 9.1 The two polynomials

We realise the two extremes by
$$f_{S_5}(x) = x^5 - x - 1, \qquad \operatorname{disc} = 2869 = 19\cdot 151,$$
$$f_{A_5}(x) = x^5 + 20x + 16, \qquad \operatorname{disc} \text{ a perfect square}.$$

The discriminant of $x^5-x-1$ deserves a remark, since a widely circulated value $-283$ belongs to a *quartic*, not to this quintic; using the wrong discriminant makes the "residue dial" of the experiment a fiction. Independent confirmation is available from the factorisation behaviour itself: primes at which $f \bmod p$ acquires a repeated factor are exactly the ramified primes, and for $f_{S_5}$ these are found computationally to be $19$ and $151$, matching $2869 = 19\cdot 151$ and not $283$. That $\operatorname{disc}(f_{A_5})$ is a square is the criterion $G \subseteq A_5$; combined with irreducibility and the presence of $5$-cycles and $(2,2)$-types it pins $G = A_5$.

### 9.2 Type censuses

Factoring each polynomial modulo all primes below $6\cdot 10^4$ (about $6000$ primes) by distinct-degree factorisation yields the following (observed density versus the Chebotarev prediction $|C|/|G|$):

| type | $f_{S_5}$ observed | predicted | $f_{A_5}$ observed | predicted |
|---|---|---|---|---|
| $[5]$ | $0.1957$ | $0.2000$ | $0.4058$ | $0.4000$ |
| $[1,4]$ | $0.2456$ | $0.2500$ | — | $0$ |
| $[2,3]$ | $0.1746$ | $0.1667$ | — | $0$ |
| $[1,1,3]$ | $0.1704$ | $0.1667$ | $0.3313$ | $0.3333$ |
| $[1,2,2]$ | $0.1250$ | $0.1250$ | $0.2477$ | $0.2500$ |
| $[1,1,1,2]$ | $0.0796$ | $0.0833$ | — | $0$ |
| $[1,1,1,1,1]$ | $0.0091$ | $0.0083$ | $0.0152$ | $0.0167$ |

All deviations are below $0.8\%$, consistent with the $O(1/\sqrt{\pi(x)})$ fluctuation expected at this sample size, and — the qualitatively decisive point — **no odd type is ever observed for $f_{A_5}$**, in any run at any size. The empirical entropies, $2.560$ and $1.647$ bits, sit at their exact values $2.55734\ldots$ and $1.65554\ldots$ to within the same tolerance.

### 9.3 The sign agreement, and why exact $0$ or $1$ matters

For every unramified prime tested, the parity of the splitting type of $f_{S_5}$ modulo $p$ agreed with the Legendre symbol $\left(\frac{2869}{p}\right)$: agreement $1.0000$ over all $6052$ primes.

An agreement rate that is exactly $0$ or exactly $1$ is the fingerprint of a law holding identically; a rate strictly between them would falsify it. In the course of the campaign an agreement of exactly $0.0000$ was once observed — a *perfect anti-correlation*, which is not a refutation but the law confirming itself through an inverted sign convention. Exact endpoints therefore function as a cheap, high-power self-check on encoding, and we recommend building them into any such experiment.

### 9.4 Plug-in bias and the permutation reference

The naive ("plug-in") estimate of $I(p \bmod m ; T)$ from a finite prime list is biased *upward*, and the bias grows with the number of classes of the dial. At the natural conductor $m = 2869$ the dial has $2868$ residue classes; with a few thousand primes each class is seen once or twice, and spurious class–type coincidences manufacture apparent information. In the campaign the raw estimate came out at
$$\hat I = 1.2157 \text{ bits},$$
i.e. $0.2157$ above the theoretical value $1$. The correct reference is not zero and not one: it is a **permutation null** designed to preserve exactly the channel the theorem predicts and to randomise only the finer assignment. Concretely, one permutes the residues *within* each parity stratum, so the one predicted bit survives intact and every additional structure is destroyed; re-estimating on the shuffled data measures the bias directly. The result,
$$\text{null} = 1.2188 \pm 0.0036,\qquad z = -0.85,$$
places the observed value *inside* its own null: the entire excess of $+0.2188$ over the exact $1$ bit is estimator bias, and no extra signal is present. The semiprime version behaves identically: $1.0648$ observed against a null of $1.0639$, a gap of $0.0009$; and the projection of the dial onto the sign stratification gives $1.0023$ against the exact value $1.0000$.

Two design rules follow, and we state them because they are the part of this work most transportable to other problems.

1. **Permutation-reference every information estimate at a large conductor.** A raw mutual information is meaningless without a null computed by the same estimator on data with the hypothesised structure preserved.
2. **A null must preserve the channel the law predicts and randomise only what is finer.** Permuting labels *within* strata, in a design where the strata are the predicted channel, deletes the very signal under test and produces a null that is trivially unbeatable; permuting the data within strata is the correct operation.

### 9.5 Measuring the seal

For $f_{A_5}$, the claim to be tested is a *zero*, which requires the same discipline in the opposite direction: a raw estimate will always be positive, so the question is whether it exceeds its null. Four residue directions were used, $m \in \{3,7,11,31\}$, each with a permutation null. Every raw value landed on its own null, worst discrepancy $|z| = 1.72$; the semiprime pair channel gave $0.0004$ bits; and no odd type was ever read out. The four-state type channel of a perfect group is sealed in every direction tested, with $1.65554\ldots$ bits of splitting entropy present and none of it audible.

### 9.6 A ledger of defects caught by design

Six genuine errors were detected and corrected by checks built into the protocol, and we list them because the list is a more useful methodological artefact than any single number:

1. **A dictionary error** in the tabulation of root counts for the type $[1,2,2]$: one quadratic factor pair contributes two roots in $\mathbb{F}_{p^2}$, not four. Detected by a crash at $p = 2$.
2. **A discriminant migration**: $\operatorname{disc}(x^5-x-1) = 2869$, not the quartic value $-283$. Detected by observing repeated factors modulo $151$.
3. **A sign-encoding inversion**, surfacing as an agreement of exactly $0.0000$ rather than $1.0000$.
4. **Plug-in bias on the headline quantity** itself ($+0.22$ bits at a $2868$-class dial), corrected by permutation referencing.
5. **A null-design error**: permuting labels within strata deletes the through-stratum channel the law predicts; one must permute the data.
6. **An identifier mismatch** that silently collapsed all strata into one, so that a stratified shuffle was in fact a global shuffle.

---

## 10. Discussion

### 10.1 What the results say, in one sentence each

- The splitting type of a prime is a rich random variable: $2.55734\ldots$ bits at $S_5$, $1.65554\ldots$ bits at $A_5$.
- Congruence conditions can read exactly $\log_2|G^{\mathrm{ab}}|$ of those bits, no more, and — when the type determines the character — no less.
- At $S_5$ that number is $1$; at $A_5$ it is $0$; and the $A_5$ zero is an identity with no free parameter.
- Combining primes does not help: the $k$-prime channel transmits the same $\log_2|\operatorname{im}\varphi|$ for every $k$.

### 10.2 Relation to classical arithmetic

None of the inputs is new: Dedekind's factorisation theorem, Chebotarev, the simplicity of $A_5$, and the fact that abelian extensions of $\mathbb{Q}$ are cyclotomic are all classical. What is new is the *exact accounting*. The classical statements are qualitative ("congruences determine splitting in abelian extensions"; "$A_5$ has no abelian quotients"); the theorems above turn them into equalities between real numbers, with the residual $H(T\mid \mathrm{sign})$ quantifying precisely the failure of abelian class field theory to describe a non-abelian extension. In this sense the paper offers an information-theoretic measure of the gap that the Langlands programme is designed to bridge.

### 10.3 Relevance to statistical learning on arithmetic data

Splitting types are attractive features: cheap, canonical, and sharply distributed. The theorems delimit their usefulness in a model-independent way.

- Against an $A_5$ quintic, **no** predictor whose inputs are congruence conditions on $p$ can achieve better than chance at predicting splitting behaviour, regardless of architecture, sample size or training budget. The mutual information is zero, so the data-processing inequality forbids any nonzero accuracy gain.
- Against an $S_5$ quintic, the total available signal is one bit, attained by a single quadratic character — so any model beating the quadratic-character baseline by a measurable margin is, provably, overfitting or leaking.
- Any reported gain from multiplying primes (semiprime features, almost-prime aggregations) is likewise spurious, by Theorem F.

Negative results of this type function as *unit tests for arithmetic machine learning*: a benchmark with a known exact capacity is a benchmark on which a well-calibrated learning pipeline must plateau at the right value.

### 10.4 Limits of the model

The uniform model is exact in the limit: Chebotarev gives natural densities, and any finite prime list deviates by fluctuations of order $\pi(x)^{-1/2}$ (conjecturally $O(x^{-1/2+\epsilon})$ error terms under GRH). Effective versions carry dependence on the conductor and the field, so the statements here are about densities, not about explicit ranges. Second, the identification of "what a residue can see" with "homomorphisms into abelian groups" is class field theory for the abelian part; a read-out depending on $p$ in a non-congruence way (say, an automorphic coefficient) is *not* covered by the seal of Theorem C — it is exactly the escape route that non-abelian reciprocity provides, and the $A_5$ case is one where such a description is known via modular forms of weight one.

---

## 11. Future directions

**Conjecture 1 (strictness away from refinement).** Let $G$ be finite, $\varphi : G \to M$ a dial into an abelian group and $T$ a conjugacy-invariant read-out. Then $I(\varphi;T) = \log_2\#\varphi(G)$ *if and only if* $T$ refines $\varphi$; otherwise $I(\varphi;T) < \log_2 \#\varphi(G)$, and the deficit equals $\sum_t P(t)\,H(\varphi \mid T = t)$. The refinement hypothesis of Theorem E should be exactly the boundary: a single type fibre meeting two dial classes contributes a strictly positive conditional term. The Frobenius group $F_{20}$ realises the strict side ($I = 3/2$ against a ceiling of $2$), so both sides of the dichotomy already have witnesses; only the equivalence is open.

**Conjecture 2 (asymptotics of the symmetric residual).** For $S_n$, the residual satisfies $H(\operatorname{cycleType}\mid\operatorname{sgn}) = H(\operatorname{cycleType}) - 1$ with
$$H(\operatorname{cycleType}) = \log_2 n! - \frac{1}{n!}\sum_{\lambda \vdash n} |C_\lambda| \log_2 |C_\lambda| = \Theta(\sqrt n),$$
and more precisely $H(\operatorname{cycleType}) \sim c\sqrt n$ for an explicit constant coming from the Hardy–Ramanujan asymptotics for the partition function. The one-bit law fixes the dial side in every degree, so the entire degree dependence of the channel is carried by the conjugacy-class histogram — an object of asymptotic combinatorics rather than of number theory. The exact degree-five value $2.55734\ldots$ anchors the sequence.

**Further directions.**

- *Complete the quintic row.* The dihedral group $D_5$ remains to be measured with a verified defining polynomial; its abelianization is $C_2$, so the predicted transmitted information is exactly one bit, while its splitting entropy should fall between the $A_5$ and $F_{20}$ values.
- *Beyond abelian dials.* Replace "homomorphism into an abelian group" by "matrix coefficient of an irreducible representation of dimension $\ge 2$" and ask for the corresponding capacity; here the $A_5$ seal must break, and quantifying by how much is a concrete non-abelian analogue of the present accounting.
- *Effective versions.* Convert the exact identities into finite-range statements with explicit error terms under GRH, so that the one-bit law becomes a statement about primes below $x$ with quantified confidence rather than about densities.
- *Higher-degree endpoints.* The tower results give the dial side in all degrees; computing $H(T)$ exactly for $n = 6,7$ and locating which transitive groups maximise it would extend the "largest entropy" observation beyond degree five.
- *A capacity view.* Treat $\log_2|G^{\mathrm{ab}}|$ as the Shannon capacity of a congruence channel and ask which coding-theoretic statements (rate, converse, strong converse) have arithmetic content.

---

## 12. Conclusion

A quintic polynomial defines a channel between the residue of a prime and the way the polynomial factors modulo that prime. The capacity of this channel is not an empirical quantity to be estimated but a group-theoretic invariant to be computed: it is $\log_2$ of the size of the abelianization of the Galois group, attained exactly when the splitting type determines the character. At the two extremes of degree five the invariant takes its extreme values. The largest splitting entropy in the family, $2.55734\ldots$ bits at $S_5$, collapses to a single quadratic-residue bit. The perfect group $A_5$ seals its $1.65554\ldots$ bits completely: no residue class, no modulus, no product of primes, no read-out of any kind can extract a single one of them. And neither statement depends on degree five — both are the first visible instances of a law that runs up the entire symmetric tower.
