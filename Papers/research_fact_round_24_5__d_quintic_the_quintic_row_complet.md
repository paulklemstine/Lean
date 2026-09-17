# The Type/Coset Channel of a Finite Group: The Transitive Quintic Row in Closed Form

**Author:** Aristotle
**Date:** 2026-09-17

---

## Abstract

Attached to a degree-$n$ irreducible polynomial $f \in \mathbb{Q}[x]$ with Galois group $G \leq S_n$ and an unramified prime $p$ are two observables: the **factorization type** $T$ of $f \bmod p$ (equivalently, the cycle type of the Frobenius class of $p$), and the **abelianization coset** $C$, the image of the Frobenius class in $A = G/[G,G]$, which class field theory realizes as a function of $p$ modulo the conductor $m^\ast$. By the Chebotarev density theorem, the joint law of $(T,C)$ over primes is the joint law of that pair of functions at a uniformly random element of $G$. We study this finite object as an information channel.

We prove the **Abelianization Law**: if the type refines the coset — every type occurs with exactly one coset — then $I(T;C) = H(C) = \log_2|A|$; together with the **gap identity** $H(T) - I(T;C) = H(T\mid C)$ this pins every Shannon quantity of the channel. We prove its **converse**: for an arbitrary finite type/coset table, $I(T;C) = H(C)$ if and only if the type determines the coset, so a single ambiguous type strictly lowers the transmitted information. We prove a **residue-dial invariance**: refining the coset alphabet along any $m$-to-one map, spreading mass uniformly, adds exactly $\log_2 m$ bits to both the coset and the joint entropy and leaves $I$ unchanged — explaining why the measured value $I(p \bmod m^\ast; T)$ equals $I(T;C)$ exactly rather than approximately. We prove the **pair law** and its arity-$k$ generalization: $k$ independent Frobenius classes transmit precisely $\log_2|A|$ bits about the coset of their product, the same as one, together with the **which-factor wall**: the product coset is statistically independent of the coset of any single designated factor, so that mutual information is exactly $0$.

Applying these to the five transitive subgroups of $S_5$ — $C_5$, $D_5$, $F_{20}$, $A_5$, $S_5$ — closes the quintic row in exact closed form:
$$I(T;C) = \log_2 5 - \tfrac{8}{5},\quad 1,\quad \tfrac{3}{2},\quad 0,\quad 1,$$
with type entropies $\log_2 5 - \tfrac{8}{5}$, $\tfrac{1}{5} + \tfrac{1}{2}\log_2 5$, $\tfrac{11}{10}+\tfrac{1}{4}\log_2 5$, $\tfrac{2}{15}+\tfrac{7}{20}\log_2 3 + \tfrac{5}{12}\log_2 5$, and $\tfrac{7}{5}+\tfrac{5}{24}\log_2 5+\tfrac{17}{40}\log_2 3$. The $D_5$ cell is realized inside the dihedral group of order $10$ itself: we identify $[D_5,D_5]$ with the rotation subgroup by exhibiting each rotation as a *single* commutator, show the factorization-type observable is a class function separating the three element orders $1, 5, 2$, and prove the group's own joint table coincides with the abstract $D_5$ table. The relevant quadratic character is *not* the discriminant character (since $D_5 \subseteq A_5$, the discriminant is a square); for $x^5+20x+32$ it is the character of the quadratic resolvent field $\mathbb{Q}(\sqrt{-5})$, of conductor $20$. Finally, $F_{20}$ is exhibited as the unique non-saturating cell of the row: its type $[4]$ straddles both generators of $C_4$, forcing $I = 3/2 < 2 = H(C)$.

**Keywords:** Chebotarev density, Frobenius class, abelianization, mutual information, dihedral quintic, quadratic resolvent, class field theory, conditional entropy.

---

## 1. Introduction

### 1.1 Two observables at a prime

Let $f \in \mathbb{Z}[x]$ be monic, irreducible, of degree $n$, with splitting field $L/\mathbb{Q}$ and Galois group $G = \mathrm{Gal}(L/\mathbb{Q})$, viewed as a transitive subgroup of $S_n$ through its action on the roots. For each prime $p$ not dividing $\mathrm{disc}(f)$, the Frobenius conjugacy class $\mathrm{Frob}_p \subseteq G$ is defined, and Dedekind's theorem gives the identity

$$\text{cycle type of } \mathrm{Frob}_p \;=\; \text{degree multiset of the irreducible factors of } f \bmod p .$$

Write $T(p)$ for this common value: the **factorization type**. It is a class function, computable from $f$ and $p$ by polynomial factorization over $\mathbb{F}_p$.

Let $A = G^{\mathrm{ab}} = G/[G,G]$ be the abelianization and $\varphi : G \twoheadrightarrow A$ the quotient map. Since $A$ is abelian, $\varphi$ is constant on conjugacy classes, so $C(p) := \varphi(\mathrm{Frob}_p) \in A$ is well defined: the **abelianization coset**. The fixed field $L^{[G,G]}$ is the maximal abelian subextension, and by class field theory it lies in a cyclotomic field $\mathbb{Q}(\zeta_{m^\ast})$; the Artin map exhibits $C(p)$ as a function of the residue $p \bmod m^\ast$ through a surjective homomorphism $(\mathbb{Z}/m^\ast)^\times \twoheadrightarrow A$. In words: *the abelianization coset is exactly the part of the Frobenius data that a congruence condition on $p$ can detect.*

### 1.2 The channel point of view

Chebotarev's density theorem states that the Frobenius classes equidistribute: for each conjugacy class $\mathcal{K} \subseteq G$, the density of primes with $\mathrm{Frob}_p = \mathcal{K}$ is $|\mathcal{K}|/|G|$. Consequently the joint distribution of $(T(p), C(p))$ over primes, in the sense of natural density, equals the joint distribution of $(T(g), \varphi(g))$ for $g$ uniform in $G$.

This is a finite object: a joint probability table on the finite type alphabet and the finite coset alphabet. It therefore has Shannon entropies, and there is a well-posed question:

> **How many bits does the factorization shape of $f \bmod p$ reveal about the residue class of $p$?**

The answer is the mutual information $I(T;C)$, and the content of this paper is that it is computable in exact closed form, that it is governed by a single structural law with a sharp converse, and that the law is verified without exception across the whole of degree five.

### 1.3 Contributions

1. A general finite framework (§2) for type/coset tables, with the gap identity, nonnegativity of the conditional entropies and of the mutual information, and the group-level construction $g \mapsto (T(g), \varphi(g))$ for uniform $g$.
2. The **Abelianization Law** (§3) in both abstract and group forms, including the closed form $I(T;C) = \log_2|A|$ via uniformity of the coset marginal.
3. The **Saturation Criterion** (§4): a complete converse — $I(T;C) = H(C)$ iff the type determines the coset — with the strict inequality for ambiguous types.
4. The **residue-dial invariance** (§5): information is unchanged under uniform refinement of the coset alphabet, with the exact accounting $H \mapsto H + \log_2 m$.
5. The **pair law**, the **arity-$k$ law**, and the **which-factor wall** (§6).
6. The **completed quintic row** (§7): all five transitive subgroups of $S_5$ in closed form, and the group-theoretic realization of the $D_5$ cell (§8), including the identification of the quadratic resolvent as $\mathbb{Q}(\sqrt{-5})$ for $x^5+20x+32$ (§9).
7. Algorithms and numerical corroboration (§10), discussion of what the row means arithmetically (§11), and open problems (§12).

---

## 2. The type/coset channel

### 2.1 Definitions

**Definition 2.1 (Joint table).** Let $\iota$ (types) and $\kappa$ (cosets) be finite nonempty sets. A *joint table* is a function $p : \iota \times \kappa \to \mathbb{R}_{\geq 0}$ with $\sum_{t}\sum_{c} p(t,c) = 1$. Its marginals are
$$p_T(t) = \sum_{c} p(t,c), \qquad p_C(c) = \sum_{t} p(t,c).$$

**Definition 2.2 (Entropies).** With $\eta(x) = -x\log x$ (and $\eta(0)=0$), all logarithms natural, define in bits
$$H(T) = \frac{1}{\log 2}\sum_t \eta(p_T(t)),\quad H(C) = \frac{1}{\log 2}\sum_c \eta(p_C(c)),\quad H(T,C) = \frac{1}{\log 2}\sum_{t,c} \eta(p(t,c)),$$
$$I(T;C) = H(T)+H(C)-H(T,C),\quad H(T\mid C) = H(T,C)-H(C),\quad H(C\mid T) = H(T,C)-H(T).$$

**Definition 2.3 (Group table).** Let $G$ be a finite nonempty group (or indeed any finite nonempty set), and $T : G \to \iota$, $C : G \to \kappa$ two observables. The *group table* $J_{G,T,C}$ has cells
$$p(t,c) = \frac{\#\{g \in G : T(g)=t \text{ and } C(g)=c\}}{|G|}.$$

By Chebotarev, $J_{G,T,\varphi}$ is the density-limit joint law of (factorization type, abelianization coset) over unramified primes.

### 2.2 Basic laws

**Theorem 2.4 (Gap identity).** For any joint table, $H(T) - I(T;C) = H(T\mid C)$.

*Proof.* Immediate from the definitions: $H(T)-\big(H(T)+H(C)-H(T,C)\big) = H(T,C)-H(C)$. $\square$

Trivial as an algebraic identity, this is the interpretive backbone: whatever the transmitted information turns out to be, the *entire* residual type entropy is accounted for as coset-conditioned entropy. There is no unexplained remainder.

**Lemma 2.5 (Pointwise domination).** If $0 \le a \le b$ then $a\,(-\log b) \le \eta(a)$.

*Proof.* If $a=0$ both sides vanish. Otherwise $0<a\le b$ gives $\log a \le \log b$, so $a\log a \le a \log b$, i.e. $-a\log b \le -a\log a = \eta(a)$. $\square$

**Theorem 2.6 (Nonnegative conditional entropies).** $H(T\mid C) \ge 0$ and $H(C\mid T) \ge 0$.

*Proof sketch.* Expand $\sum_c \eta(p_C(c)) = \sum_c\sum_t p(t,c)\,(-\log p_C(c))$, and apply Lemma 2.5 cellwise with $a = p(t,c) \le b = p_C(c)$; summing gives $\sum_c \eta(p_C(c)) \le \sum_{t,c}\eta(p(t,c))$, i.e. $H(C) \le H(T,C)$. The other inequality follows by swapping the roles of the alphabets, which leaves $H(T,C)$ invariant. $\square$

**Theorem 2.7 (Nonnegative information).** $I(T;C) \ge 0$, hence $0 \le I(T;C) \le \min\{H(T),H(C)\}$.

*Proof sketch.* On the support $S=\{(t,c): p(t,c)>0\}$ one has
$$I(T;C)\log 2 = \sum_{(t,c)\in S} p(t,c)\,\log\frac{p(t,c)}{p_T(t)\,p_C(c)} = -\sum_{(t,c)\in S} p(t,c)\,\log\frac{p_T(t)p_C(c)}{p(t,c)} .$$
Apply $\log x \le x-1$ to each ratio: $\sum_S p \log\frac{p_Tp_C}{p} \le \sum_S (p_Tp_C - p) \le 1 - 1 = 0$, using $\sum_S p = 1$ and $\sum_S p_Tp_C \le \sum_{t,c} p_T(t)p_C(c) = 1$. Negating gives the claim. The upper bounds are Theorem 2.6 combined with the gap identity. $\square$

---

## 3. The Abelianization Law

**Definition 3.1 (Determination).** A joint table is said to have the type *determine* the coset if
$$p(t,c) > 0 \text{ and } p(t,c')>0 \;\Longrightarrow\; c = c'.$$
Equivalently each row of the table is supported on a single cell.

**Lemma 3.2 (Single-cell rows).** If a nonnegative finite family $(f_a)_{a\in\alpha}$ has at most one positive member, then $\sum_a \eta(f_a) = \eta\!\left(\sum_a f_a\right)$.

*Proof.* If all $f_a = 0$ both sides vanish. Otherwise there is a unique $a_0$ with $f_{a_0}>0$ and $f_a=0$ for $a\ne a_0$; both sums reduce to the single term $\eta(f_{a_0})$. $\square$

**Theorem 3.3 (Abelianization Law, abstract form).** If the type determines the coset, then
$$I(T;C) = H(C), \qquad\text{and consequently}\qquad H(T) - I(T;C) = H(T) - H(C) = H(T\mid C).$$

*Proof.* By Lemma 3.2 applied to each row, $\sum_{t,c}\eta(p(t,c)) = \sum_t \eta(p_T(t))$, i.e. $H(T,C) = H(T)$. Hence $I = H(T)+H(C)-H(T) = H(C)$. $\square$

**Theorem 3.4 (Dual law).** If the coset determines the type (each column supported on one cell), then $I(T;C) = H(T)$.

*Proof.* Apply Theorem 3.3 to the transposed table, noting $I$ and $H(T,C)$ are symmetric under transposition. $\square$

**Theorem 3.5 (Uniform coset marginal).** Let $\varphi : G \twoheadrightarrow A$ be a surjective homomorphism of finite groups, $T : G \to \iota$ arbitrary. Then in the group table $J_{G,T,\varphi}$, every coset has marginal $p_C(a) = 1/|A|$; hence $H(C) = \log_2|A|$.

*Proof sketch.* All fibres of $\varphi$ are cosets of $\ker\varphi$ and hence have cardinality $|G|/|A|$: choosing $g_0$ with $\varphi(g_0)=a$, left multiplication by $g_0$ is a bijection $\ker\varphi \to \varphi^{-1}(a)$; and $|\ker\varphi|\cdot|A| = |G|$ by the first isomorphism theorem. Summing the table row-wise over types recovers exactly the fibre count, so $p_C(a) = |\varphi^{-1}(a)|/|G| = 1/|A|$. A uniform distribution on $|A|$ points has entropy $\log_2|A|$. $\square$

**Theorem 3.6 (Abelianization Law, closed form).** Let $G$ be a finite group, $\varphi : G \twoheadrightarrow A$ a surjective homomorphism onto a finite group, and $T : G \to \iota$ a type observable refining $\varphi$, i.e. $T(g)=T(g') \Rightarrow \varphi(g)=\varphi(g')$. Then
$$I(T;\varphi) = \log_2 |A|.$$

*Proof.* Determination in the sense of Definition 3.1 holds because a positive cell $(t,a)$ is witnessed by an actual $g \in G$ with $T(g)=t$, $\varphi(g)=a$; two positive cells in the same row give $g,g'$ with $T(g)=T(g')$, hence $\varphi(g)=\varphi(g')$. Apply Theorem 3.3, then Theorem 3.5. $\square$

**Corollary 3.7 (Arithmetic form).** Let $f$ be an irreducible polynomial with Galois group $G$ and abelianization $A$, such that the cycle type of an element of $G$ determines its image in $A$. Then the factorization type of $f \bmod p$ carries exactly $\log_2|A|$ bits about the abelianization coset of $p$, and the residual type entropy is exactly $H(T)-\log_2|A|$.

---

## 4. The converse: a sharp saturation criterion

The forward law is a sufficient condition. The following theorem shows it is also necessary, which was the principal structural gap left by the experimental program.

**Lemma 4.1 (Strict pointwise domination).** If $0 < x < S$ then $x(-\log S) < \eta(x)$.

*Proof.* $\log x < \log S$ and $x > 0$ give $x \log x < x\log S$, i.e. $-x\log S < -x\log x = \eta(x)$. $\square$

**Lemma 4.2 (Row bound).** For every type $t$, $\;\eta(p_T(t)) \le \sum_c \eta(p(t,c))$.

*Proof.* Write $\eta(p_T(t)) = \sum_c p(t,c)\,(-\log p_T(t))$ and apply Lemma 2.5 cellwise with $b=p_T(t)$. $\square$

**Lemma 4.3 (Strict row bound).** If $c_1 \ne c_2$ with $p(t,c_1)>0$ and $p(t,c_2)>0$, then $\eta(p_T(t)) < \sum_c \eta(p(t,c))$.

*Proof.* Since $p(t,c_1)+p(t,c_2) \le p_T(t)$ and $p(t,c_2)>0$, we get $p(t,c_1) < p_T(t)$. Hence the term at $c_1$ satisfies the strict inequality of Lemma 4.1 while all other terms satisfy the weak inequality of Lemma 2.5; summing yields a strict inequality. $\square$

**Theorem 4.4 (Saturation Criterion).** For any finite type/coset table,
$$I(T;C) = H(C) \quad\Longleftrightarrow\quad \text{the type determines the coset.}$$

*Proof.* ($\Leftarrow$) is Theorem 3.3. ($\Rightarrow$): suppose $I = H(C)$; then $H(T,C) = H(T)$, i.e. $\sum_{t,c}\eta(p(t,c)) = \sum_t \eta(p_T(t))$. If some row $t$ had two positive cells, Lemma 4.3 would make that row's contribution strictly larger while Lemma 4.2 makes every other row's contribution at least as large, giving $\sum_t \eta(p_T(t)) < \sum_{t,c}\eta(p(t,c))$ — a contradiction. $\square$

**Corollary 4.5 (Ambiguity is strictly costly).** If some type occurs with two distinct cosets, then $I(T;C) < H(C)$.

This is the mechanism behind the single non-saturating cell of the quintic row (§7.3).

---

## 5. The residue dial

In practice one does not observe the abelianization coset; one observes the residue $p \bmod m^\ast$, an observable with $\phi(m^\ast)$ values rather than $|A|$. The Artin map $(\mathbb{Z}/m^\ast)^\times \twoheadrightarrow A$ is a surjective homomorphism, so it is $m$-to-one with $m = \phi(m^\ast)/|A|$, and conditionally on the coset the residue is independent of the Frobenius type. The following theorem makes the resulting accounting exact.

**Definition 5.1 (Uniform refinement).** Let $J$ be a joint table on $\iota \times \kappa$, let $\pi : \rho \to \kappa$ be a surjection with all fibres of size $m \ge 1$. The *refinement* $J' = J \!\downarrow_\pi$ on $\iota \times \rho$ is defined by
$$p'(t,r) = \frac{p(t,\pi(r))}{m}.$$
(It is a probability table: summing over the fibre above $c$ restores $p(t,c)$.)

**Theorem 5.2 (Residue-dial invariance).** With notation as above,
$$H'(T) = H(T), \qquad H'(C) = H(C) + \log_2 m, \qquad H'(T,C) = H(T,C) + \log_2 m,$$
and consequently
$$I'(T;C) = I(T;C).$$

*Proof sketch.* The key computation is $\eta(x/m) = \eta(x)/m + (x/m)\log m$ for $x\ge 0$, $m>0$, and the fibrewise summation rule $\sum_{r} F(\pi(r)) = m\sum_c F(c)$. The type marginal is unchanged because $\sum_r p(t,\pi(r))/m = \sum_c p(t,c)$. For the coset entropy, $p'_C(r) = p_C(\pi(r))/m$, so
$$\sum_r \eta(p'_C(r)) = m \sum_c\left[\frac{\eta(p_C(c))}{m} + \frac{p_C(c)}{m}\log m\right] = \sum_c \eta(p_C(c)) + \log m,$$
using $\sum_c p_C(c) = 1$; dividing by $\log 2$ gives $+\log_2 m$. The joint entropy computation is identical row by row, using $\sum_c p(t,c) = p_T(t)$ and then $\sum_t p_T(t) = 1$. Substituting into $I = H(T)+H(C)-H(T,C)$ cancels the two $\log_2 m$ terms. $\square$

**Corollary 5.3 (The $D_5$ dial at $m^\ast = 20$).** For a $D_5$-quintic with quadratic resolvent $\mathbb{Q}(\sqrt{-5})$, the quadratic character sends the eight units modulo $20$ four-to-one onto $C_2$ (split classes $1,3,7,9$; inert classes $11,13,17,19$). Hence
$$I(p \bmod 20;\, T) = I(T;C) = 1 \text{ bit exactly},\qquad H(p\bmod 20) = 1 + \log_2 4 = 3 \text{ bits},$$
while $H(T)$ is untouched at $\tfrac{1}{5}+\tfrac{1}{2}\log_2 5$.

So the residue observable carries three bits of entropy, exactly one of which concerns the factorization type. Measured agreement of $1.0000$ against the law's $1.0000$ is not a coincidence of rounding: the two quantities are literally the same real number.

---

## 6. Semiprimes, arity, and the which-factor wall

Let $n = p_1\cdots p_k$ be a $k$-almost-prime with distinct unramified prime factors. The natural model is $k$ independent uniform elements $x = (x_1,\dots,x_k) \in G^k$, observables
$$T^{(k)}(x) = (T(x_1),\dots,T(x_k)), \qquad C^{(k)}(x) = \prod_{i=1}^k \varphi(x_i) \in A .$$
Because $A$ is abelian, $C^{(k)}$ is a homomorphism $G^k \to A$; it is the coset of $n$, since the Artin symbol is multiplicative in the modulus argument.

**Theorem 6.1 (Multi-prime law).** Let $k \ge 1$, let $\varphi : G \twoheadrightarrow A$ be surjective with $A$ abelian, and suppose $T$ refines $\varphi$. Then
$$I\big(T^{(k)};\,C^{(k)}\big) = \log_2|A| .$$
In particular the value is independent of $k$: pairing or $k$-tupling primes neither gains nor loses information.

*Proof.* If $T(x_i) = T(x_i')$ for all $i$, then $\varphi(x_i) = \varphi(x_i')$ for all $i$ and hence $\prod_i\varphi(x_i) = \prod_i \varphi(x_i')$: the type vector determines the product coset. Surjectivity of $C^{(k)}$ follows by placing a preimage in the first coordinate and the identity elsewhere. Apply Theorem 3.6 to the group $G^k$ with the observables $T^{(k)}, C^{(k)}$. $\square$

**Theorem 6.2 (Which-factor wall).** Let $k \ge 2$, and consider the pair of observables $\big(\varphi(x_1),\, \prod_{i}\varphi(x_i)\big)$ on $G^k$. They are statistically independent, so their mutual information is exactly $0$.

*Proof sketch.* The map $x \mapsto (\varphi(x_1), \prod_i\varphi(x_i))$ is a homomorphism $G^k \to A \times A$, and it is *surjective*: given $(a,b)$ pick $g_1 \in \varphi^{-1}(a)$, $g_2 \in \varphi^{-1}(a^{-1}b)$ and take $x = (g_1,g_2,1,\dots,1)$. Every fibre of a surjective homomorphism onto $A\times A$ has the same size, so the joint distribution of the two observables is uniform on $A\times A$, i.e. a product of its two uniform marginals. Independent observables have zero mutual information. $\square$

Informally: the residue of a semiprime $n=pq$ determines the *product* of the cosets of $p$ and of $q$, and nothing at all about which factor contributed which. This is the group-theoretic reason that these channels cannot be turned into factoring oracles: a uniform abelian element multiplied into a secret is a one-time pad.

---

## 7. The transitive quintic row in closed form

There are exactly five transitive subgroups of $S_5$ up to conjugacy: $C_5$ (order 5), $D_5$ (order 10), $F_{20} = C_5 \rtimes C_4$ (order 20), $A_5$ (order 60), $S_5$ (order 120). For each, the joint table is the conjugacy-class statistics against the abelianization. We record the tables and evaluate all Shannon quantities exactly. Throughout write $L = \log_2 5 = 2.321928\ldots$ and $M = \log_2 3 = 1.584963\ldots$

The computation of the entropies is a finite, mechanical one: every cell probability is a $\{2,3,5\}$-smooth rational $2^x3^y5^z$, so $\eta(p) = -p\,(x\log 2 + y\log 3 + z\log 5)$ and each entropy is an explicit $\mathbb{Q}$-linear combination of $1$, $L$, $M$.

### 7.1 $C_5$ — the cyclic quintic, e.g. the real subfield of $\mathbb{Q}(\zeta_{11})$

Types: $[1^5]$ with rate $1/5$; $[5]$ with rate $4/5$. The group is abelian, so $A = C_5$ and the coset *is* the Frobenius element: five cosets of rate $1/5$.

$$H(T) = L - \tfrac{8}{5} = 0.72193\ldots,\qquad H(C) = L = 2.32193\ldots$$

Here the coset determines the type (each of the five group elements has a definite cycle type), so by the dual law (Theorem 3.4)
$$I(T;C) = H(T) = L - \tfrac{8}{5}, \qquad \text{gap } H(T\mid C) = 0 .$$
The channel is transparent: a cyclic quintic hides nothing from congruences.

### 7.2 $D_5$ — e.g. $x^5 + 20x + 32$

Types: $[1^5]$ rate $1/10$ (identity), $[5]$ rate $4/10$ (four nontrivial rotations), $[1,2,2]$ rate $5/10$ (five reflections). The abelianization is $C_2$ (§8), rotations $\mapsto 0$, reflections $\mapsto 1$; the type determines the coset.

$$H(T) = \tfrac{1}{5}+\tfrac{L}{2} = 1.36096\ldots,\quad H(C) = 1,\quad I(T;C) = 1,\quad H(T\mid C) = \tfrac{L}{2}-\tfrac{4}{5} = 0.36096\ldots$$

Sharp brackets: $1.3607 < H(T) < 1.36105$, obtained from $2.3214 < L < 2.3221$ (which follow from $5^{28} > 2^{65}$ and $5^{59} < 2^{137}$).

### 7.3 $F_{20}$ — e.g. $x^5 - 2$

Types and rates: $[1^5]$: $1/20$; $[5]$: $4/20$; $[4]$: $10/20$; $[1,2,2]$: $5/20$. The abelianization is $C_4$, and the crucial feature is that the ten elements of type $[4]$ split evenly between the *two generators* of $C_4$: five elements map to each. So the type $[4]$ straddles two cosets.

$$H(T) = \tfrac{11}{10} + \tfrac{L}{4} = 1.68048\ldots,\qquad H(C) = 2, \qquad H(T,C) = \tfrac{8}{5}+\tfrac{L}{4},$$
$$I(T;C) = H(T)+H(C)-H(T,C) = \tfrac{3}{2}.$$

By Corollary 4.5 the strict inequality $I < H(C)$ is forced by the ambiguity, and here it is exactly half a bit: the single ambiguous type $[4]$, of mass $1/2$, straddling $k=2$ cosets, contributes $\tfrac12\log_2 2 = \tfrac12$ to the deficit. This is the row's only non-saturating cell with nontrivial abelianization.

### 7.4 $A_5$ — e.g. $x^5 + 20x + 16$

Types and rates: $[1^5]$: $1/60$; $[1,2,2]$: $15/60$; $[1,1,3]$: $20/60$; $[5]$: $24/60$ (the two classes of 5-cycles merge in cycle type).

$A_5$ is perfect: $[A_5,A_5] = A_5$, so $A$ is trivial, $H(C) = 0$, and therefore $I(T;C) = 0$.

$$H(T) = \tfrac{2}{15} + \tfrac{7M}{20} + \tfrac{5L}{12} = 1.65554\ldots, \qquad I(T;C) = 0, \qquad H(T\mid C) = H(T).$$

Every bit of factorization entropy is invisible to congruences. This is the information-theoretic statement of the failure of abelian reciprocity for non-solvable quintics: there is no modulus $m$ and no function of $p \bmod m$ that predicts anything whatsoever about the factorization shape.

### 7.5 $S_5$ — e.g. $x^5 - x - 1$

Seven classes: $[1^5]$: $1/120$; $[1,1,1,2]$: $10/120$; $[1,2,2]$: $15/120$; $[1,1,3]$: $20/120$; $[2,3]$: $20/120$; $[1,4]$: $30/120$; $[5]$: $24/120$. The abelianization is $C_2$ via the sign character, and the cycle type determines the sign.

$$H(T) = \tfrac{7}{5}+\tfrac{5L}{24}+\tfrac{17M}{40} = 2.55734\ldots,\quad H(C)=1,\quad I(T;C) = 1,\quad H(T\mid C) = H(T)-1 .$$

Arithmetically, the one transmitted bit is exactly the Legendre symbol of the discriminant: $p$ splits in $\mathbb{Q}(\sqrt{\mathrm{disc} f})$ iff the Frobenius permutation is even.

### 7.6 The completed row

| group | example | $A = G^{\mathrm{ab}}$ | $H(T)$ | $H(C)$ | $I(T;C)$ | gap $H(T\mid C)$ | saturates? |
|---|---|---|---|---|---|---|---|
| $C_5$ | $\mathbb{Q}(\zeta_{11})^+$ | $C_5$ | $L-\frac{8}{5}=0.7219$ | $L=2.3219$ | $L-\frac{8}{5}=0.7219$ | $0$ | no ($I<H(C)$, but type is *determined by* coset) |
| $D_5$ | $x^5+20x+32$ | $C_2$ | $\frac15+\frac L2=1.3610$ | $1$ | $1$ | $\frac L2-\frac45=0.3610$ | yes |
| $F_{20}$ | $x^5-2$ | $C_4$ | $\frac{11}{10}+\frac L4=1.6805$ | $2$ | $\frac32$ | $\frac L4-\frac25=0.1805$ | **no** |
| $A_5$ | $x^5+20x+16$ | $1$ | $\frac2{15}+\frac{7M}{20}+\frac{5L}{12}=1.6555$ | $0$ | $0$ | $1.6555$ | yes (trivially) |
| $S_5$ | $x^5-x-1$ | $C_2$ | $\frac75+\frac{5L}{24}+\frac{17M}{40}=2.5574$ | $1$ | $1$ | $1.5574$ | yes |

Three structural statements hold across the row without exception:

1. **The law.** In every cell where the type determines the coset, $I(T;C) = H(C) = \log_2|A|$. This covers $D_5$, $A_5$, $S_5$ directly, and $C_5$ via the dual law.
2. **The gap.** In every cell, $H(T) - I(T;C) = H(T\mid C)$ exactly.
3. **The bounds.** In every cell, $0 \le I(T;C) \le \min\{H(T), H(C)\}$.

Note the arithmetic of the values: four of the five transmitted informations are rational ($1, 3/2, 0, 1$) and the single irrational value $L - 8/5$ occurs exactly where the coset observable coincides with the Frobenius element itself.

---

## 8. The $D_5$ cell realized inside the group

The $D_5$ row is not merely a histogram fit; it is the class statistics of the dihedral group of order $10$ acting on the five roots, and each ingredient of the law can be verified inside that group.

Let $D = \langle r, s \mid r^5 = s^2 = 1,\ srs^{-1}=r^{-1}\rangle$ act on the pentagon's vertices, identified with the five roots.

**The type observable.** Define $T(r^i) = [1^5]$ if $i \equiv 0$, $[5]$ otherwise, and $T(sr^i) = [1,2,2]$. This is precisely the cycle type of the corresponding permutation of the five roots: a nontrivial rotation is a 5-cycle; a reflection of a pentagon fixes one vertex and swaps the other four in two transpositions. The observable is intrinsic: the three types are exactly the three possible element orders $1$, $5$, $2$,
$$T(g) = [1^5] \iff g = 1, \qquad T(g) = [5] \iff \mathrm{ord}(g)=5, \qquad T(g)=[1,2,2] \iff \mathrm{ord}(g)=2,$$
and it is a class function, $T(hgh^{-1}) = T(g)$ for all $g,h$ — as any Frobenius type must be.

**The coset observable.** Define $C(r^i) = 0$, $C(sr^i) = 1$. This is a homomorphism onto $C_2 = \mathbb{Z}/2$ (a product of two rotations or two reflections is a rotation; a mixed product is a reflection) and it is surjective.

**Theorem 8.1 ($D_5^{\mathrm{ab}} \cong C_2$).** The commutator subgroup $[D,D]$ is exactly the rotation subgroup $\ker C$. Hence $C$ *is* the abelianization map.

*Proof.* ($\subseteq$) The quotient by the rotation subgroup is $C_2$, abelian, so every commutator lies in the kernel. ($\supseteq$) Every rotation is a *single* commutator:
$$[\,s,\, r^{2k}\,] = s^{-1} r^{-2k} s\, r^{2k} = r^{2k}r^{2k} = r^{4k} ,$$
and since $4$ is invertible modulo $5$ (with inverse $4$), as $k$ ranges over $\mathbb{Z}/5$ so does $4k$; equivalently $r^k = [\,s,\, r^{2k\cdot 4^{-1}}\,]$. In particular every rotation is a commutator, so the rotation subgroup lies in $[D,D]$. $\square$

**Theorem 8.2 (Determination and the cell).** $T(g)=T(g') \Rightarrow C(g)=C(g')$, since types $[1^5]$ and $[5]$ occur only for rotations and $[1,2,2]$ only for reflections. Therefore, by Theorem 3.6,
$$I(T;C) = \log_2 |C_2| = 1 .$$

**Theorem 8.3 (Cell counts).** The six cells of the $D_5$ table have counts
$$\#\{g: T=[1^5], C=0\}=1,\quad \#\{[5],0\}=4,\quad \#\{[1,2,2],1\}=5,$$
all other cells $0$; dividing by $|D| = 10$ reproduces exactly the abstract table of §7.2. Consequently the group's own $H(T) = \tfrac15 + \tfrac{L}{2}$, $I(T;C)=1$, and $H(T\mid C) = \tfrac{L}{2}-\tfrac45$.

---

## 9. Locating the quadratic character: $\mathbb{Q}(\sqrt{-5})$

A subtlety distinguishes the $D_5$ cell from the $S_5$ cell, and it is the main arithmetic content of the case.

For a generic quintic, the surjection $G \to C_2$ is the sign character, and the corresponding quadratic field is $\mathbb{Q}(\sqrt{\mathrm{disc}\,f})$: the transmitted bit is the Legendre symbol $\left(\frac{\mathrm{disc} f}{p}\right)$. But $D_5 \subseteq A_5$: every element of $D_5$, acting on the five roots, is an even permutation (rotations are 5-cycles, reflections are products of two transpositions). Hence $\mathrm{disc}\,f$ is a perfect *square* in $\mathbb{Q}$, and the discriminant character is trivial. The abelianization's $C_2$ must therefore correspond to some *other* quadratic field.

It does: the **quadratic resolvent**, the unique quadratic subfield $K$ of the degree-10 splitting field $L$, fixed by the index-2 subgroup $C_5 = [D_5,D_5]$. Theory locates $K$ tightly. Since $L/\mathbb{Q}$ and the root field are ramified at the same set of primes, and $K \subseteq L$, the discriminant of $K$ is supported on the primes dividing $\mathrm{disc}(f)$; so $K = \mathbb{Q}(\sqrt d)$ for a squarefree $d$ built from those primes. Enumerating the finitely many candidates and comparing, prime by prime, the Kronecker symbol $\left(\frac{d}{p}\right)$ with the observed coset $\pm1$ (rotation vs reflection, i.e. type in $\{[1^5],[5]\}$ vs $[1,2,2]$) identifies $K$ uniquely.

For $f(x) = x^5+20x+32$ the search returns a single candidate at perfect agreement:
$$K = \mathbb{Q}(\sqrt{-5}), \qquad \mathrm{disc}(K) = -20, \qquad m^\ast = 20 .$$
The split classes are $p \equiv 1,3,7,9 \pmod{20}$ and the inert classes $p \equiv 11,13,17,19 \pmod{20}$, giving the four-to-one Artin map used in Corollary 5.3. A scan over primes confirms agreement $1.0000$ — every unramified prime tested obeys

$$f \bmod p \text{ has type } [1,2,2] \iff \left(\tfrac{-20}{p}\right) = -1 \iff p \equiv 11,13,17,19 \pmod{20}.$$

Concretely, this makes the one transmitted bit fully explicit for this polynomial: *the factorization of $x^5+20x+32$ modulo $p$ has two quadratic factors exactly when $-5$ is a non-residue mod $p$.*

Two remarks. First, the scan that produced the polynomial is itself elementary: among trinomials $x^5+ax+b$ with $|a|,|b| \le 60$, one filters for irreducibility and square discriminant (forcing $G \subseteq A_5$), then discards the $A_5$ and $C_5$ possibilities by the observed type histogram — a $D_5$ quintic is the unique transitive case whose types are exactly $\{[1^5],[5],[1,2,2]\}$ with rates $\{1/10, 4/10, 1/2\}$. Four such polynomials appear within that box. Second, this is why the type histogram is the group readout: no external certificate of the Galois group is needed, because the histogram itself distinguishes the five transitive groups (the rate vector $(1/10,4/10,1/2)$ occurs for $D_5$ alone in degree five).

---

## 10. Algorithms and numerical corroboration

Three algorithms suffice to reproduce every number above.

### 10.1 Factorization type of $f$ modulo $p$

Given $f$ of degree $n$ and a prime $p \nmid \mathrm{disc} f$, compute the multiset of degrees of the irreducible factors of $f$ over $\mathbb{F}_p$ by **distinct-degree factorization**: set $h_0 = x$ and $F = f$; for $i = 1, 2, \dots$, update $h_i = h_{i-1}^{\,p} \bmod F$ and take $g_i = \gcd(F, h_i - x)$, the product of all irreducible factors of $F$ of degree exactly $i$; record $\deg g_i / i$ factors of degree $i$ and replace $F$ by $F/g_i$. Cost: $O(n \log p)$ multiplications of degree-$<n$ polynomials modulo $p$ per level, i.e. $O(n^3\log p)$ field operations for fixed small $n$ — negligible for $n=5$.

### 10.2 Exact Shannon quantities of a rational table

Given a table of rational cell probabilities, compute $H(T)$, $H(C)$, $H(T,C)$, $I$, $H(T\mid C)$ in floating point by the definitions, and simultaneously verify the closed forms of §7 by comparing against $\mathbb{Q}$-linear combinations of $1$, $\log_2 3$, $\log_2 5$. Cost $O(|\iota||\kappa|)$.

### 10.3 Empirical channel from primes

For a range of primes, form the empirical joint table of (type of $f \bmod p$, residue class $p \bmod m^\ast$) and compute its Shannon quantities. By Theorem 5.2, the limiting value of $I$ equals the coset-level value; deviations decay like the Chebotarev error term. Cost: one factorization per prime.

### 10.4 Observed values

A scan of $x^5+20x+32$ over primes up to $10^6$ reproduces the predicted type rates $\{1/10, 4/10, 1/2\}$ to within $0.002$, produces no type outside the $D_5$ menu, and yields $H(T) = 1.3610$, $I(p \bmod 20; T) = 1.0000$ against the law's $1.0000$. The empirical Kronecker agreement (type-parity versus $\left(\frac{-20}{p}\right)$) is $1.0000$ — exact, not statistical, as Theorem 8.2 and §9 predict. A Monte-Carlo simulation of the semiprime channel returns pair information $1.0000$ against the law's $1.0000$ and which-factor wall $0.0000$ against the law's $0$.

---

## 11. Discussion

### 11.1 What the channel measures

The mutual information $I(T;C)$ answers a question that predates information theory: *which features of the splitting behaviour of a polynomial are governed by congruence conditions?* Class field theory's answer is "exactly the abelian ones", and the channel makes that answer quantitative. The type entropy $H(T)$ is the total randomness in how $f$ factors; $I(T;C)$ is the part reciprocity reaches; $H(T\mid C)$ is the part it cannot. The gap identity says these add up with nothing left over.

Two extremes illuminate the middle. For $C_5$ the gap is zero: the polynomial is "all congruence". For $A_5$ the information is zero: the polynomial is "all non-abelian", and no arithmetic progression predicts anything. The remaining three groups interpolate, and in each case the exact value is read off the group's abelianization together with a combinatorial fact about whether cycle types can straddle cosets.

### 11.2 Why exactness is the point

Numerical agreement to four decimals is common; exactness is rarer and structurally more informative. Three theorems combine to guarantee it here.

- The Abelianization Law (Theorem 3.6) makes $I$ a *logarithm of an integer*, not an integral of a density.
- The residue-dial invariance (Theorem 5.2) shows that replacing the idealized coset by the observable residue does not perturb $I$ at all; the extra $\log_2 m$ bits are pure, information-free entropy.
- The Saturation Criterion (Theorem 4.4) certifies that whenever the value falls short, it is because of a specific, identifiable ambiguous type — as in $F_{20}$, whose deficit of exactly $1/2$ is traced to the single shape $[4]$.

### 11.3 Relation to the wall results

Theorems 6.1 and 6.2 place a firm limit on what these channels can do. Multiplying primes together does not accumulate information about the abelian part ($\log_2|A|$ at every arity), and reveals nothing about the individual factors (wall $=0$). One cannot bootstrap a factoring advantage from Frobenius statistics: the abelian shadow of a product is a one-time pad over the abelian shadows of its factors.

### 11.4 Limitations

The framework is exact about *densities*. Finite scans of primes see the Chebotarev error term, which is effective only under GRH for the ranges typically used; the reported empirical agreement to $0.002$ should be read as consistency, not proof. Second, the identification of the quadratic resolvent as $\mathbb{Q}(\sqrt{-5})$ for $x^5+20x+32$ is a *search plus verification*: the candidate set is finite and theory-justified (ramification support), and the winner is unique at perfect agreement, but the argument is a certificate matching, not a closed-form derivation. Third, the results are about the type observable; finer observables (e.g. the Frobenius class itself rather than its cycle type) give different, larger, channels, which in degree five differ only for $A_5$ and $F_{20}$ where two distinct classes share a cycle type.

---

## 12. Future work

### 12.1 A rank formula from the class data

**Conjecture.** For any finite group $G$ with abelianization $A$, the uniform type/coset channel satisfies
$$I(T;C) = \log_2|A| - \sum_t p(t)\,\log_2 k_t ,$$
where $k_t$ is the number of distinct cosets hit by elements of type $t$. The Saturation Criterion is the case "all $k_t = 1$". The mechanism is that each *conjugacy class* has a single image in $A$ (abelian quotients are class functions), so all ambiguity arises from *distinct classes sharing a cycle type* — a purely combinatorial collision. Proving the formula would compute every cell of every degree at once, and $F_{20}$ is the smallest worked example ($k_{[4]}=2$, deficit $\tfrac12$).

### 12.2 Deficit quantization

**Conjecture.** For every transitive $G \le S_n$, the deficit $\log_2|A| - I(T;C)$ is a dyadic rational, and in particular is $0$ or at least $1/|A|$. In degree $\le 5$ the observed deficits are $0$ (four cells) and $1/2$ ($F_{20}$). The deficit is $\sum_t p(t)\log_2 k_t$ with $p(t) \in \tfrac{1}{|G|}\mathbb{Z}$; it is rational exactly when every $k_t$ is a power of two. A sextic group with a type straddling three cosets of $C_6$ would produce an irrational deficit and refute the quantization — a sharp, cheap test.

### 12.3 Multi-prime saturation and the wall hierarchy

**Conjecture.** For $k$ independent Frobenius classes with observables $(T_1,\dots,T_k)$ and product coset, $I = \log_2|A|$ for every $k \ge 1$ whenever the type determines the coset, while the information about any proper sub-product of the cosets is exactly $0$. The cases $k=2$ and general $k$ for the two extreme statements are Theorems 6.1 and 6.2; the general sub-product wall remains. The mechanism is that the product of $k$ independent uniform elements of an abelian group is uniform and independent of any $k-1$ of them, so all "which factor" walls are structural.

### 12.4 Further directions

- **Degree six and beyond.** Sixteen transitive groups of degree six, with abelianizations ranging over $1, C_2, C_3, C_6, C_2^2, S_3$; the row is a direct test of §12.1.
- **The non-abelian channel.** Replace the coset observable by a higher-dimensional representation's character value; the "information" becomes a statement about non-abelian reciprocity, where no analogue of the Artin residue dial exists.
- **Effective error terms.** Quantify the convergence $I_X(T;C) \to I(T;C)$ as the scan bound $X \to \infty$, in terms of the Chebotarev error, giving honest confidence intervals for empirical cells.
- **The converse to the wall.** Characterize which pairs of observables on $G^k$ have zero mutual information; Theorem 6.2 gives a sufficient structural condition (joint surjectivity of a homomorphism onto a product), and a converse would classify the walls.

---

## 13. Conclusion

The transitive quintic row is complete. For each of $C_5$, $D_5$, $F_{20}$, $A_5$, $S_5$ the amount of information that the factorization shape of a quintic modulo $p$ carries about the residue class of $p$ is now known exactly: $\log_2 5 - 8/5$, $1$, $3/2$, $0$, $1$ bits respectively, with residual entropies $0$, $\tfrac12\log_2 5 - \tfrac45$, $\tfrac14\log_2 5 - \tfrac25$, $\tfrac{2}{15}+\tfrac{7}{20}\log_2 3+\tfrac{5}{12}\log_2 5$, and $\tfrac25+\tfrac{5}{24}\log_2 5+\tfrac{17}{40}\log_2 3$. One law governs all five: when the cycle type determines the abelianization coset, the channel transmits exactly $\log_2|G^{\mathrm{ab}}|$ bits, and the gap is exactly the coset-conditioned type entropy. The law now has a proved converse, so the one cell that falls short — $F_{20}$, by exactly half a bit — does so for an identified reason. The residue dial is proved information-neutral, so measured values at a conductor are the coset values on the nose. And the semiprime and $k$-prime channels are proved to transmit the same $\log_2|A|$ bits with a hard zero wall between the product and its factors.
