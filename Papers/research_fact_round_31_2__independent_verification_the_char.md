# The Abelian Ceiling: Exactly $\log_2 \lvert G^{\mathrm{ab}} \rvert$ Bits of Frobenius Information Are Visible in a Residue

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Let $K/\mathbb{Q}$ be a number field whose Galois closure has group $G$, and let $T$ denote the splitting type of an unramified rational prime $p$ — equivalently, the cycle type of its Frobenius conjugacy class. Under the Chebotarev (uniform) measure on $G$, we determine exactly how much of the entropy of $T$ is accessible from a congruence condition on $p$.

Our main theorem is that for **every** finite group $G$ and **every** surjective homomorphism $\chi : G \to C$ onto a finite abelian group $C$, the mutual information between the Frobenius conjugacy class and $\chi$ equals $\log_2 \lvert C \rvert$ exactly, with no further hypothesis; and that every read-out factoring through $\chi$ is bounded above by $\log_2 \lvert C \rvert$, the bound being attained by $\chi$ itself. Since, by class field theory, the read-outs of the Frobenius that are congruence conditions on $p$ are precisely those factoring through the abelianization $G^{\mathrm{ab}}$, the theorem is a hard ceiling on reciprocity: **a residue reveals at most $\log_2\lvert G^{\mathrm{ab}}\rvert$ bits about the splitting type, and exactly that many when the ceiling is attained.**

The running example is the $S_3$ cubic field defined by $x^3+x+1$, of discriminant $-31$. There the Chebotarev densities are $\Pr[\texttt{111}] = 1/6$, $\Pr[\texttt{12}] = 1/2$, $\Pr[\texttt{3}] = 1/3$, giving $H(T) = \tfrac23 + \tfrac{\log_2 3}{2} = 1.4591\ldots$ bits; the quadratic character $\left(\frac{-31}{\cdot}\right)$ is the sign of the Frobenius; the residual is $H(T \mid \mathrm{sign}) = \tfrac12 H(\tfrac13,\tfrac23) = \tfrac{\log_2 3}{2} - \tfrac13 = 0.4591\ldots$ bits; and the mutual information is $1$ bit **exactly**, the two irrational terms cancelling identically. We also prove the strictness of the statement (a coarser read-out falls strictly below the ceiling), the mirror dichotomy (an abelian Galois group hides nothing: $I = \log_2\lvert G\rvert$), and the uniform one-bit law for all symmetric groups $S_n$, $n \ge 2$. Finally we explain the empirically observed *mixed-type residue classes* as a forced consequence of the theorem rather than as noise.

**Keywords:** Chebotarev density, Frobenius element, quadratic character, mutual information, abelianization, class field theory, splitting type, non-abelian residual.

---

## 1. Introduction

### 1.1 The question

Fix a monic irreducible $f \in \mathbb{Z}[x]$ of degree $n$ and let $K = \mathbb{Q}[x]/(f)$, with Galois closure $L$ and group $G = \mathrm{Gal}(L/\mathbb{Q}) \le S_n$. For each prime $p$ not dividing $\operatorname{disc}(f)$, the factorization of $f$ modulo $p$ into irreducibles has degrees forming a partition $T(p) \vdash n$, and the Frobenius conjugacy class $\mathrm{Frob}_p \subseteq G$ has cycle type exactly $T(p)$.

Chebotarev's density theorem says that $\mathrm{Frob}_p$ equidistributes over conjugacy classes: the natural density of primes whose Frobenius lies in a class $\mathcal{C}$ is $\lvert \mathcal{C}\rvert / \lvert G\rvert$. Thus the splitting type $T$ is, in the density sense, a random variable obtained by drawing $\sigma \in G$ uniformly and reading off its cycle type.

Some information about $T$ is available *cheaply*, as a congruence condition on $p$. The classical instance is the discriminant character: $\left(\frac{\operatorname{disc}(f)}{p}\right) = \mathrm{sgn}(\mathrm{Frob}_p)$, and by quadratic reciprocity the left side depends only on $p$ modulo $\lvert\operatorname{disc}(f)\rvert$. More generally, class field theory identifies the read-outs of $\mathrm{Frob}_p$ that are determined by congruences on $p$ with the read-outs that factor through the abelianization $G^{\mathrm{ab}} = G/[G,G]$: these are precisely the characters cut out by the abelian subextensions of $L/\mathbb{Q}$, whose Frobenius data are governed by the Artin reciprocity map and therefore by residues modulo the conductor.

The question of this paper is quantitative:

> **How many bits of the splitting type are congruence-visible?**

### 1.2 The answer

Exactly $\log_2 \lvert G^{\mathrm{ab}} \rvert$. Not "at most, generically"; exactly, and it is a ceiling for all congruence read-outs simultaneously.

For $G = S_n$ this is one bit, for every $n \ge 2$, while $H(T)$ grows without bound; the congruence-visible fraction of the arithmetic tends to $0$. For abelian $G$ it is $\log_2\lvert G\rvert = H(\mathrm{Frob})$: everything. For a perfect group ($G^{\mathrm{ab}}$ trivial) it is $0$: nothing at all.

### 1.3 Contributions

1. An elementary counting-entropy calculus on a finite group under the uniform measure, with the chain rule and the symmetry of mutual information proved from scratch (Section 2).
2. The **exact-information theorem** $I(\mathrm{class};\chi) = \log_2\lvert C\rvert$ for every surjective character into a finite abelian group, with *no* refinement hypothesis (Section 4).
3. The **abelian ceiling** $I(\mathrm{class}; u\circ\chi) \le \log_2\lvert C\rvert$ for arbitrary post-processing $u$, with attainment (Section 4).
4. The **exact deficit** $H(\mathrm{class}\mid\chi) = H(\mathrm{class}) - \log_2\lvert C\rvert$ (Section 4).
5. A complete quantitative treatment of the $S_3$ field $x^3+x+1$, disc $-31$, including the exact entropies, four-decimal numerical brackets, and the decomposition $H(T\mid \mathrm{sign}) = \tfrac12 H(\tfrac13,\tfrac23)$ (Section 5).
6. Strictness and rigidity companions: a mixed fibre forces a strict loss, so the one-bit result is a statement about the *splitting type* and not an artefact (Section 6).
7. The explanation of mixed-type residue classes, and the dichotomy with abelian fields (Sections 5.4, 7).

---

## 2. The counting-entropy calculus

Throughout, $s$ is a nonempty finite set (in the application, the group $G$), and a *read-out* is any function $g$ from $s$ to a set with decidable equality. All measures are uniform on $s$; this is the Chebotarev measure when $s = G$.

### Definition 2.1 (Uniform entropy)

For a read-out $g : s \to \beta$, write $s_g(a) = \{x \in s : g(x) = g(a)\}$ for the fibre through $a$. The **uniform entropy** of $g$ is

$$H_s(g) \;=\; \log_2 \lvert s\rvert \;-\; \frac{1}{\lvert s\rvert}\sum_{a \in s} \log_2 \lvert s_g(a)\rvert .$$

Grouping the sum by fibres shows this is Shannon's entropy of the pushforward distribution: if the distinct values of $g$ have fibres of sizes $n_1,\dots,n_r$ with $\sum n_i = N = \lvert s\rvert$, then

$$H_s(g) \;=\; -\sum_{i=1}^{r} \frac{n_i}{N}\log_2\frac{n_i}{N}.$$

### Definition 2.2 (Conditional entropy)

For read-outs $g$ and $k$,

$$H_s(g \mid k) \;=\; \sum_{v \in k(s)} \frac{\lvert s_k^{-1}(v)\rvert}{\lvert s\rvert}\; H_{s_k^{-1}(v)}(g),$$

the average entropy of $g$ over the fibres of $k$, where $s_k^{-1}(v) = \{x\in s : k(x) = v\}$.

### Definition 2.3 (Mutual information)

$$I_s(g;k) \;=\; H_s(g) - H_s(g\mid k).$$

We drop the subscript $s$ when it is clear. The following four facts are all we need; each is elementary but each is used essentially.

### Lemma 2.4 (Constancy)

If $g$ is constant on $s$ then $H(g) = 0$.

*Proof.* Every fibre is all of $s$, so each summand $\log_2\lvert s\rvert - \log_2\lvert s\rvert$ vanishes. $\square$

### Theorem 2.5 (Chain rule)

For any read-outs $g,k$ on a nonempty $s$,

$$H(g \mid k) \;=\; H\big((g,k)\big) - H(k),$$

where $(g,k)$ is the joint read-out $x \mapsto (g(x),k(x))$.

*Proof sketch.* Expand the definition of $H(g\mid k)$: the fibre of $(g,k)$ through $x$ is the intersection of the fibre of $g$ within the fibre of $k$ through $x$. Writing each entropy as $\log_2$ of a cardinality minus an average of $\log_2$ of fibre cardinalities and regrouping the double sum over fibres of $k$ turns the identity into the telescoping statement $\log_2\lvert s\rvert - \log_2\lvert s^{-1}_k(v)\rvert$ summed with the right weights. $\square$

### Corollary 2.6 (Symmetry)

$I(g;k) = I(k;g)$ for nonempty $s$.

*Proof.* By the chain rule both equal $H(g) + H(k) - H((g,k))$, using that the joint read-out is insensitive to the order of its components. $\square$

Symmetry is the engine of the whole paper: it converts the hard direction ("how much does a character tell you about the splitting type?") into the trivial direction ("how much does the splitting type tell you about the character?").

### Lemma 2.7 (Non-negativity and the cap)

$H(g\mid k)\ge 0$; consequently $I(g;k) \le H(g)$ and, by symmetry, $I(g;k) \le H(k)$.

### Lemma 2.8 (Post-processing)

For any map $u$, $H(u \circ k) \le H(k)$.

*Proof sketch.* Each fibre of $u\circ k$ is a union of fibres of $k$, so fibres only grow; the entropy formula is monotone decreasing in fibre sizes. (Equivalently, this is the data-processing inequality for a deterministic channel.) $\square$

### Lemma 2.9 (Refinement kills conditional entropy)

If $g$ refines $k$ on $s$, meaning $g(x) = g(y) \Rightarrow k(x) = k(y)$ for $x,y \in s$, then $H(k \mid g) = 0$.

*Proof.* On each fibre of $g$ the read-out $k$ is constant; apply Lemma 2.4 and average. $\square$

### Lemma 2.10 (Strict positivity)

If $k(x)\ne k(y)$ for some $x,y \in s$, then $H(k) > 0$. If moreover $g(x)=g(y)$ while $k(x)\ne k(y)$ — a *mixed fibre* — then $H(k\mid g) > 0$.

*Proof sketch.* A fibre of $k$ is then a proper nonempty subset of $s$, so at least one term $\log_2\lvert s\rvert - \log_2\lvert s_k(a)\rvert$ is strictly positive while all terms are non-negative; the conditional statement is the same argument applied inside the fibre of $g$ containing $x$ and $y$, whose weight is positive. $\square$

---

## 3. Balanced read-outs

### Theorem 3.1 (A balanced $m$-valued read-out carries exactly $\log_2 m$ bits)

Let $m \ge 1$ and suppose that every fibre of $k$ has size $\lvert s\rvert/m$, i.e. $m \cdot \lvert s_k(a)\rvert = \lvert s\rvert$ for all $a \in s$. Then

$$H(k) = \log_2 m.$$

*Proof.* For each $a$, $\log_2\lvert s_k(a)\rvert = \log_2\lvert s\rvert - \log_2 m$. Substituting into Definition 2.1, the average of the constant $\log_2\lvert s\rvert - \log_2 m$ is itself, and $H(k) = \log_2\lvert s\rvert - (\log_2\lvert s\rvert - \log_2 m) = \log_2 m$. $\square$

The case $m=2$ — a *balanced binary* read-out carries exactly one bit — is the one that produces the headline result; the general case is what upgrades "one bit" to "$\log_2\lvert G^{\mathrm{ab}}\rvert$ bits".

### Theorem 3.2 (One bit from a balanced binary refinement)

Let $k$ be a balanced binary read-out ($2\lvert s_k(a)\rvert = \lvert s\rvert$ for all $a$) and let $g$ refine $k$. Then

$$I(g;k) = 1, \qquad H(g \mid k) = H(g) - 1.$$

*Proof.* By symmetry (Corollary 2.6), $I(g;k) = I(k;g) = H(k) - H(k\mid g)$. Lemma 2.9 gives $H(k\mid g)=0$, and Theorem 3.1 gives $H(k)=1$. The second identity is $I(g;k) = H(g) - H(g\mid k)$ rearranged. $\square$

Note what is *not* assumed: nothing about the richness of $g$. Whether $g$ is the full conjugacy class of a group of order $6$ or of order $120!$, if it refines a balanced binary read-out then exactly one bit passes.

---

## 4. The abelian ceiling

Let $G$ now be a finite group with the uniform measure, and let $\mathrm{cl} : G \to \mathrm{ConjClasses}(G)$, $\sigma \mapsto [\sigma]$, be the conjugacy-class read-out — the complete arithmetic datum attached to an unramified prime by Chebotarev.

### Lemma 4.1 (Fibres of a surjective character)

Let $C$ be a finite group and $\chi : G \to C$ a surjective homomorphism. Then every fibre of $\chi$ has exactly $\lvert G\rvert/\lvert C\rvert$ elements; equivalently $\lvert C\rvert \cdot \lvert \chi^{-1}(\chi(a))\rvert = \lvert G\rvert$ for all $a\in G$.

*Proof.* Fibres are cosets of $\ker\chi$, hence all of the same size; partitioning $G$ into the $\lvert C\rvert$ fibres (all nonempty by surjectivity) gives $\lvert G\rvert = \lvert C\rvert\cdot\lvert\ker\chi\rvert$. $\square$

### Corollary 4.2

$H(\chi) = \log_2\lvert C\rvert$ for a surjective character $\chi : G \to C$. (Theorem 3.1 with $m = \lvert C\rvert$.)

### Lemma 4.3 (Abelian characters are class functions)

If $C$ is abelian and $\chi : G \to C$ is a homomorphism, then $\chi$ is constant on conjugacy classes: $\chi(cxc^{-1}) = \chi(c)\chi(x)\chi(c)^{-1} = \chi(x)\chi(c)\chi(c)^{-1} = \chi(x)$.

Consequently $\mathrm{cl}$ *always* refines $\chi$; no hypothesis relating the two read-outs is needed.

### Theorem 4.4 (Exact visible information)

Let $G$ be a finite group, $C$ a finite abelian group, and $\chi : G \to C$ a surjective homomorphism. Then

$$I\big(\mathrm{cl};\chi\big) \;=\; \log_2 \lvert C\rvert.$$

*Proof.* By symmetry, $I(\mathrm{cl};\chi) = H(\chi) - H(\chi\mid \mathrm{cl})$. Lemma 4.3 says $\mathrm{cl}$ refines $\chi$, so Lemma 2.9 gives $H(\chi\mid\mathrm{cl}) = 0$; Corollary 4.2 gives $H(\chi) = \log_2\lvert C\rvert$. $\square$

### Theorem 4.5 (The exact deficit)

Under the hypotheses of Theorem 4.4,

$$H\big(\mathrm{cl}\mid \chi\big) \;=\; H(\mathrm{cl}) \;-\; \log_2\lvert C\rvert .$$

*Proof.* Immediate from $I(\mathrm{cl};\chi) = H(\mathrm{cl}) - H(\mathrm{cl}\mid\chi)$ and Theorem 4.4. $\square$

Everything the Frobenius class knows beyond $\log_2\lvert C\rvert$ bits is invisible to $\chi$ — and, by the next theorem, invisible to *anything computed from* $\chi$.

### Theorem 4.6 (The abelian ceiling)

Let $\chi : G \to C$ be a surjective character onto a finite abelian group and let $u : C \to \delta$ be an arbitrary map into a set with decidable equality. Then

$$I\big(\mathrm{cl}; u\circ\chi\big)\;\le\;\log_2\lvert C\rvert,$$

with equality for $u = \mathrm{id}$.

*Proof.* By the cap (Lemma 2.7), $I(\mathrm{cl};u\circ\chi) \le H(u\circ\chi)$; by post-processing (Lemma 2.8), $H(u\circ\chi)\le H(\chi)$; by Corollary 4.2, $H(\chi) = \log_2\lvert C\rvert$. Attainment is Theorem 4.4. $\square$

### Corollary 4.7 (Index-two quotient: exactly one bit)

If $\lvert C\rvert = 2$ then $I(\mathrm{cl};\chi) = 1$ and every read-out factoring through $\chi$ satisfies $I \le 1$.

### 4.1 Arithmetic interpretation

Take $C = G^{\mathrm{ab}}$ and $\chi$ the canonical surjection. By the Artin reciprocity law, the maximal abelian subextension of $L/\mathbb{Q}$ has Galois group $G^{\mathrm{ab}}$ and is contained in a cyclotomic field $\mathbb{Q}(\zeta_N)$ for $N$ the conductor; the image of $\mathrm{Frob}_p$ in $G^{\mathrm{ab}}$ is a function of $p \bmod N$, and conversely every read-out of $\mathrm{Frob}_p$ determined by a congruence on $p$ factors through $G^{\mathrm{ab}}$. Theorem 4.6 therefore says:

> **No congruence condition on $p$, of any modulus, reveals more than $\log_2\lvert G^{\mathrm{ab}}\rvert$ bits about the splitting type of $p$; the canonical character attains this, so the bound is exact.**

For a degree-$n$ field with full symmetric Galois group, $G^{\mathrm{ab}} = C_2$ and the ceiling is $1$ bit, attained by the discriminant character.

### Corollary 4.8 (Abelian fields hide nothing)

If $G$ itself is abelian, take $\chi = \mathrm{id}_G$, which is surjective onto $C = G$. Then $\mathrm{cl}$ is the identity read-out (classes are singletons) and

$$I(\mathrm{cl};\chi) = \log_2\lvert G\rvert = H(\mathrm{cl}),$$

the entire Frobenius entropy. The deficit of Theorem 4.5 is $0$. Cyclotomic and quadratic fields are informationally transparent: the residue determines the splitting completely. This is quadratic reciprocity, and its cyclotomic generalization, read as an information-theoretic statement.

---

## 5. The $S_3$ cubic $x^3+x+1$, disc $-31$

### 5.1 Setup

Let $f(x) = x^3+x+1$, irreducible over $\mathbb{Q}$, with discriminant $-4\cdot 1^3 - 27\cdot 1^2 = -31$, squarefree and negative, hence $G = S_3$. Identify $G$ with $\mathrm{Perm}(\{1,2,3\})$ and define the **splitting type** of $\sigma$ as its cycle type padded by fixed points, a partition of $3$:

$$T(\sigma) \;=\; \text{cycle type of } \sigma \;+\; \underbrace{1 + \cdots + 1}_{3 - \lvert\mathrm{supp}(\sigma)\rvert}.$$

The image of $T$ is $\{\texttt{111},\texttt{12},\texttt{3}\}$, i.e. $\{1,1,1\}$, $\{2,1\}$, $\{3\}$, with fibre sizes

$$\lvert T^{-1}(\texttt{111})\rvert = 1,\qquad \lvert T^{-1}(\texttt{12})\rvert = 3,\qquad \lvert T^{-1}(\texttt{3})\rvert = 2,$$

out of $\lvert S_3\rvert = 6$: the Chebotarev densities $1/6$, $1/2$, $1/3$.

The **quadratic character** is $\left(\frac{-31}{p}\right)$, which equals the sign of the Frobenius permutation. As a function of the splitting type,

$$\mathrm{sgn} = \varepsilon\circ T, \qquad \varepsilon(t) = \begin{cases} -1, & t = \texttt{12},\\ +1, & t \in \{\texttt{111},\texttt{3}\}.\end{cases}$$

That the sign factors through the type is the *only* arithmetic input to what follows; everything else is group theory and counting.

### 5.2 The two entropies

### Proposition 5.1 (Type entropy)

$$H(T) \;=\; \frac23 + \frac{\log_2 3}{2} \;=\; 1.4591\ldots$$

*Proof.* With $N = 6$ and fibre sizes $1,3,2$,
$$H(T) = \log_2 6 - \tfrac16\big(\log_2 1 + 3\log_2 3 + 2\log_2 2\big) = \log_2 6 - \tfrac{\log_2 3}{2} - \tfrac13 = 1 + \log_2 3 - \tfrac{\log_2 3}{2} - \tfrac13,$$
which is $\tfrac23 + \tfrac{\log_2 3}{2}$. $\square$

### Theorem 5.2 (Exactly one bit)

$$I\big(T;\mathrm{sgn}\big) \;=\; 1.$$

*Proof.* The sign read-out on $S_3$ is balanced: three odd elements, three even. And $T$ refines $\mathrm{sgn}$ because $\mathrm{sgn} = \varepsilon\circ T$. Apply Theorem 3.2. (Alternatively, Theorem 4.4 with $\chi = \mathrm{sgn}$, $C = \{\pm 1\}$.) $\square$

### Corollary 5.3 (The locked residual)

$$H\big(T\mid \mathrm{sgn}\big) \;=\; H(T) - 1 \;=\; \frac{\log_2 3}{2} - \frac13 \;=\; 0.4591\ldots$$

### Proposition 5.4 (The decomposition $H(T\mid\mathrm{sgn}) = \tfrac12 H(\tfrac13,\tfrac23)$)

$$H\big(T \mid \mathrm{sgn}\big) \;=\; \frac12\Big(\log_2 3 - \frac23\Big) \;=\; \frac12\,H\!\left(\tfrac13,\tfrac23\right).$$

*Proof.* The odd fibre (the three transpositions) is pure of type $\texttt{12}$ and contributes $0$. The even fibre (identity and two three-cycles) has type distribution $(\tfrac13,\tfrac23)$, entropy $-\tfrac13\log_2\tfrac13 - \tfrac23\log_2\tfrac23 = \log_2 3 - \tfrac23$. Each fibre has weight $\tfrac12$. Adding gives $\tfrac12(\log_2 3 - \tfrac23) = \tfrac{\log_2 3}{2} - \tfrac13$, matching Corollary 5.3. $\square$

### 5.3 Numerical brackets

The exact formulas contain $\log_2 3$; to four decimals one uses the rational sandwich

$$\frac{84}{53} \;<\; \log_2 3 \;<\; \frac{65}{41},$$

equivalent to the integer inequalities $3^{53} > 2^{84}$ and $3^{41} < 2^{65}$, which are finite computations. These yield

$$1.4591 < H(T) < 1.4594, \qquad 0.4591 < H(T\mid \mathrm{sgn}) < 0.4594,$$

and in particular $H(T\mid\mathrm{sgn}) > 0$: the non-abelian residual is strictly positive, so the splitting type is genuinely not a function of the residue. The channel is strictly lossy, $I(T;\mathrm{sgn}) = 1 < H(T)$, with visible fraction $1/H(T) = 68.5\ldots\%$.

### 5.4 Mixed-type residue classes are forced

An empirical scan of primes by residue class modulo $31$ finds that $15$ of the residue classes host **two distinct splitting types**: both $\texttt{111}$ and $\texttt{3}$ occur among the primes in the class. This is not a defect of the scan; it is exactly what the theory demands.

Indeed, the character separates only even from odd. Within the even class of $S_3$ the counts are $1$ (identity, type $\texttt{111}$) against $2$ (three-cycles, type $\texttt{3}$), a $1:2$ split that is *the same for every even residue class*, since the residue determines only the value $+1$ of the character and nothing more. Formally: there exist $\sigma,\tau \in S_3$ with $\mathrm{sgn}(\sigma) = \mathrm{sgn}(\tau)$ but $T(\sigma) \ne T(\tau)$ (take $\sigma = \mathrm{id}$, $\tau$ a three-cycle). Pure residue classes throughout would force $H(T\mid \mathrm{sgn}) = 0$, contradicting Corollary 5.3. The observed $15$ mixed classes are the $15$ classes with $\left(\frac{-31}{p}\right) = +1$ — a direct, countable manifestation of the $0.4591$ hidden bits.

---

## 6. Strictness: the result is about the *type*

One might worry that "exactly one bit" is an artefact of the framework, true for any read-out whatever. It is not.

### Definition 6.1

Let $\mathrm{sc} : S_3 \to \{\text{true},\text{false}\}$ be the coarse read-out "does $p$ split completely?", i.e. $\mathrm{sc}(\sigma) = [\,T(\sigma) = \texttt{111}\,]$.

### Proposition 6.2 (A mixed fibre)

A transposition and a three-cycle have the same value of $\mathrm{sc}$ (both false) but opposite signs.

### Theorem 6.3 (Coarsening strictly loses)

$$I\big(\mathrm{sc};\mathrm{sgn}\big) \;<\; 1 \;=\; I\big(T;\mathrm{sgn}\big).$$

*Proof.* By symmetry, $I(\mathrm{sc};\mathrm{sgn}) = H(\mathrm{sgn}) - H(\mathrm{sgn}\mid \mathrm{sc}) = 1 - H(\mathrm{sgn}\mid\mathrm{sc})$. Proposition 6.2 exhibits a fibre of $\mathrm{sc}$ on which $\mathrm{sgn}$ is non-constant, so by Lemma 2.10 $H(\mathrm{sgn}\mid \mathrm{sc}) > 0$. $\square$

(Numerically, $\mathrm{sc}$ has fibre sizes $1$ and $5$; the mixed fibre of size $5$ contains $3$ odd and $2$ even elements, giving $I(\mathrm{sc};\mathrm{sgn}) = 1 - \tfrac56 H(\tfrac35,\tfrac25) = 0.1908\ldots$ bits.)

So the full splitting type strictly beats its natural coarsening, and the value $1$ genuinely records a property of the pair (type, character).

---

## 7. Symmetric groups, and the shape of the general landscape

### Theorem 7.1 (One bit for every symmetric group)

For every finite set with at least two points, the cycle type of a uniformly random permutation and its sign satisfy

$$I(\text{cycle type};\mathrm{sgn}) = 1, \qquad H(\text{cycle type}\mid\mathrm{sgn}) = H(\text{cycle type}) - 1.$$

*Proof.* The sign is a surjective homomorphism onto a two-element group (surjective as soon as a transposition exists), hence balanced by Lemma 4.1, and it is a function of the cycle type. Apply Theorem 3.2. $\square$

### Corollary 7.2 (One-bit ceiling for permutations)

No read-out of a permutation, however fine, can extract more than one bit about the sign: $I(g;\mathrm{sgn}) \le H(\mathrm{sgn}) = 1$ for every $g$.

Since $H(\text{cycle type})$ over $S_n$ grows like $\Theta(\log n)$ — the cycle-type distribution is the Ewens measure at parameter $1$, with $\Pr[\lambda] = 1/z_\lambda$, $z_\lambda = \prod_i i^{m_i} m_i!$ — the hidden residual $H(T)-1$ diverges. Concretely, for $S_3$, $S_4$, $S_5$, $S_6$ one finds $H(T) = 1.4591, 2.0944, 2.5573, 3.0353$ bits and hidden residuals $0.4591, 1.0944, 1.5573, 2.0353$ bits. The visible fraction falls from $68.5\%$ to $47.8\%$ to $39.1\%$ to $33.0\%$.

Combining the results, the landscape is:

| Galois group $G$ | $G^{\mathrm{ab}}$ | congruence-visible bits | hidden bits |
|---|---|---|---|
| abelian | $G$ | $\log_2\lvert G\rvert$ (all) | $0$ |
| $S_n$, $n\ge 2$ | $C_2$ | $1$ | $H(T)-1 \to \infty$ |
| $A_n$, $n \ge 5$ (perfect) | trivial | $0$ | $H(T)$ (all) |
| general $G$ | $G/[G,G]$ | $\log_2\lvert G^{\mathrm{ab}}\rvert$ | $H(\mathrm{cl}) - \log_2\lvert G^{\mathrm{ab}}\rvert$ |

---

## 8. Algorithms

The results support three concrete computations, all elementary but worth stating precisely.

### 8.1 Exact channel evaluation from a group table

**Input.** A finite group $G$ (as a list of elements with multiplication), a read-out $g$, a read-out $k$.
**Output.** $H(g)$, $H(k)$, $H(g\mid k)$, $I(g;k)$ exactly (as rational combinations of logarithms, or in floating point).

The algorithm partitions $G$ by $k$, computes the entropy of $g$ within each block, averages with block weights, and subtracts. Complexity $O(\lvert G\rvert)$ hash operations. Applied to $S_3$ with $g = T$ and $k = \mathrm{sgn}$ it returns $1.4591\ldots$, $1$, $0.4591\ldots$, $1$.

### 8.2 The ceiling certificate

**Input.** A finite group $G$ and a surjective character $\chi : G \to C$ with $C$ abelian.
**Output.** The certified ceiling $\log_2\lvert C\rvert$ together with a verification that all fibres of $\chi$ have size $\lvert G\rvert/\lvert C\rvert$ and that $\chi$ is constant on conjugacy classes.

By Theorem 4.6 the output is a valid upper bound for $I(\mathrm{cl};w)$ over **all** post-processed read-outs $w = u\circ\chi$, of which there are $\sum_{m} S(\lvert C\rvert,m)$ (Bell-number-many) — so the certificate replaces an exponential search by an $O(\lvert G\rvert)$ check. One can, additionally, enumerate all set partitions of $C$ and confirm empirically that the maximum over $u$ is attained at $u=\mathrm{id}$; for $\lvert C\rvert \le 5$ this is instant.

### 8.3 Empirical Chebotarev scan with residue stratification

**Input.** A monic integer cubic $f$, a bound $X$, the modulus $N = \lvert\operatorname{disc} f\rvert$.
**Output.** For each residue $r$ coprime to $N$, the empirical distribution of splitting types among primes $p \le X$ with $p\equiv r \pmod N$; the empirical $H(T)$, $H(T\mid p \bmod N)$, $I$.

Factorization type modulo $p$ is computed by distinct-degree factorization, or for a cubic simply by counting roots in $\mathbb{F}_p$: three roots $\Rightarrow$ `111`, one root $\Rightarrow$ `12`, no root $\Rightarrow$ `3`. Cost $O(\pi(X)\cdot p)$ naively, $O(\pi(X)\log p)$ with fast exponentiation. The empirical mutual information converges to $1$, and the residue-stratified table exhibits the $15$ mixed classes of Section 5.4.

---

## 9. Discussion

### 9.1 What is really being said

The theorem is a *conservation law for arithmetic information*. The Frobenius class carries $H(\mathrm{cl})$ bits. Class field theory makes an abelian portion of that legible as congruences; the size of the legible portion is not "most of it" or "an asymptotically negligible part of it" but precisely $\log_2\lvert G^{\mathrm{ab}}\rvert$ — a quantity depending only on the abelianization, blind to everything else about $G$. In particular, two groups with wildly different class structures but the same abelianization leak the same number of bits.

The proof is short and structural. It has to be: the assertion is an equality between an information-theoretic quantity and the logarithm of a group order, and any argument that went through the arithmetic of a specific field could not produce so clean a statement. The essential moves are (i) symmetry of mutual information, which puts the trivial direction on top, and (ii) the observation that abelian characters are class functions, which supplies the refinement for free.

### 9.2 Relation to reciprocity and Langlands

Abelian class field theory is exactly the assertion that the $\log_2\lvert G^{\mathrm{ab}}\rvert$ bits *are* available; our ceiling is the converse assertion that nothing else is. The non-abelian residual is what the Langlands program addresses by replacing congruence conditions with coefficients of automorphic forms: for the $S_3$ cubic of discriminant $-31$, the remaining $0.4591$ bits are supplied not by $p \bmod 31$ but by the coefficients $a_p$ of the weight-one cusp form attached to the two-dimensional Galois representation, which distinguishes the identity class from the three-cycles by $a_p = 2$ versus $a_p = -1$. In information-theoretic terms, that modular form is precisely a device for transmitting the bits the residue cannot.

### 9.3 Limits of the framework

Three caveats. First, the measure is the exact Chebotarev measure; the theorems are statements about densities, and any finite prime scan approximates them with an error governed by effective Chebotarev bounds (and, conditionally on GRH, by $O(X^{1/2}\log X)$ error terms). Second, we quantify information about the *conjugacy class*, which for $S_n$ is the same as the cycle type; for a general Galois group with several classes of the same cycle type, splitting type is a coarsening of the class and the exact-information theorem should be applied with care (the ceiling remains valid, since it holds for all read-outs). Third, the entropies here are all "one-prime" quantities; joint distributions over several primes are independent under Chebotarev, so the per-prime numbers simply multiply the count, but correlations induced by conditioning on global data are outside the scope.

### 9.4 A remark on the cancellation

It is worth dwelling on why $1.4591\ldots - 0.4591\ldots = 1$ exactly. Both quantities contain $\tfrac{\log_2 3}{2}$, which measures the same object twice: the biased $1:2$ coin inside the even class. In $H(T)$ it appears because the type distribution is $(\tfrac16,\tfrac12,\tfrac13)$; in $H(T\mid\mathrm{sgn})$ it appears because the even fibre splits $1:2$. The character learns nothing about that coin, so it cancels, and what remains is the balanced coin the character *does* see. The exact integer is thus not an accident of small numbers but the arithmetic shadow of a short exact sequence $1 \to A_3 \to S_3 \to C_2 \to 1$.

---

## 10. Future work

**Equality-case rigidity.** The ceiling proof factors as $I \le H(w) \le H(\chi) = \log_2\lvert C\rvert$, with both inequalities equalities exactly when the corresponding conditional entropies vanish. We conjecture that $I(\mathrm{cl};w) = \log_2\lvert C\rvert$ holds **iff** $w$ separates the fibres of $\chi$ — i.e. the ceiling is attained only by read-outs from which the character can be recovered. What is missing is the quantitative gap: an inequality $\log_2\lvert C\rvert - I \ge c\cdot(\text{defect})$ for an explicit measure of defect, which should follow from strict concavity of $-p\log p$ rather than from any arithmetic.

**The exact residual for $S_n$.** For every $n\ge2$ the residual is $H(T\mid\mathrm{sgn}) = H(T)-1$, where $H(T)$ is the entropy of the partition distribution $p(\lambda) = 1/z_\lambda$, $z_\lambda = \prod_i i^{m_i}m_i!$. A closed form, $H(T) = \log_2 n! - \frac{1}{n!}\sum_{\lambda\vdash n}\frac{n!}{z_\lambda}\log_2\frac{n!}{z_\lambda}$, together with the growth rate $H(T) - 1 = \Theta(\log n)$, would make the divergence of the hidden information quantitative.

**Multiplicativity over composita.** For number fields $K_1,K_2$ with coprime discriminants and groups $G_1,G_2$, we expect $I(\mathrm{cl};\text{residue}) = \log_2\lvert G_1^{\mathrm{ab}}\rvert + \log_2\lvert G_2^{\mathrm{ab}}\rvert$ for the compositum, since $(G_1\times G_2)^{\mathrm{ab}} = G_1^{\mathrm{ab}}\times G_2^{\mathrm{ab}}$: the visible information is additive while total type entropy is subadditive, so the hidden fraction grows under composition.

**Beyond deterministic read-outs.** Replacing $u\circ\chi$ by a noisy channel would place the ceiling in the setting of the data-processing inequality for general Markov kernels; the bound $\log_2\lvert G^{\mathrm{ab}}\rvert$ should persist, and the equality case should become a statement about sufficient statistics.

**Higher moments.** Beyond entropy, the whole distribution of $\log$-likelihood ratios between the residue-conditional and unconditional type distributions is computable in closed form for $S_n$; large-deviation rates for "how atypical can a residue class look" would sharpen the empirical scans.

---

## 11. Conclusion

For the cubic field of discriminant $-31$, the quadratic character captures **exactly one bit** of the $1.4591\ldots$ bits of splitting-type entropy, leaving $0.4591\ldots$ bits locked behind the non-abelian structure of $S_3$. The one is $\log_2 2$, and $2 = \lvert S_3^{\mathrm{ab}}\rvert$; the coincidence is a theorem. For any finite group $G$ and any surjective character onto a finite abelian group $C$, the Frobenius class and the character share exactly $\log_2\lvert C\rvert$ bits; every read-out computable from the character is capped at that value; and the deficit is exactly $H(\mathrm{cl}) - \log_2\lvert C\rvert$. Abelian Galois groups hide nothing; symmetric groups hide everything but one bit.
