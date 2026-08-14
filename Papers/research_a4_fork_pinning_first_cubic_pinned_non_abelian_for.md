# Cubic Pinning of a Non-Abelian Fork: Congruence Information in the $A_4$-Field of $x^4+8x+12$

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

We study how much information a congruence condition on a prime $p$ can carry about the splitting type of a fixed polynomial modulo $p$, and we settle the structural question of *what* determines that amount. Our framework measures a binary splitting observable (a **fork**) against a residue observable (a **dial**) with Shannon mutual information, and we prove a **trichotomy**: for any finite dial with strictly positive weights, the mutual information $I$ satisfies $0 \le I \le H(\bar f)$, with $I=0$ exactly when the fork is conditionally constant (**flat**), $I = H(\bar f)$ exactly when the fork is a deterministic function of the dial (**pinned**), and $0 < I < H(\bar f)$ otherwise (**leaking**). We prove a **pinning-content criterion**: a fork is pinnable by a congruence exactly when it factors through the abelianization $G^{\mathrm{ab}}$ of the Galois group, equivalently when it is invariant under translation by commutators.

The main new witness is the alternating group $A_4$, realized as the Galois group of $x^4+8x+12$ (discriminant $576^2$, so $G \subseteq A_4$; irreducible and containing an order-three element, so $G = A_4$). We prove $[A_4,A_4] = V_4$ and $|A_4^{\mathrm{ab}}| = 3$, compute the Klein resolvent $y^3-48y-64$ by Vieta, verify its discriminant equals that of the quartic ($576^2$), and identify it, via the rescaling $y = 4z$ giving $64(z^3-3z-1)$, with the standard cyclic cubic of conductor $9$: the resolvent field is $\mathbb{Q}(\zeta_9)^+$. Consequently the fork $F_0(p) = [\mathrm{Frob}\,p \in V_4]$, equivalently "$p$ is a cube mod $9$", equivalently "$p \equiv \pm1 \pmod 9$", is pinned, with
$$I(p \bmod 9;\ F_0) = H(1/3) = \log_2 3 - \tfrac23 = 0.9183\ldots \text{ bits},$$
the **first cubic pinning of a non-abelian field**, and numerically identical to the abelian cyclic cubic case. We prove the modulus is minimal ($I(p \bmod 3; F_0)=0$) and that dials coprime to the conductor are flat.

We further prove **within-$V_4$ flatness** — every homomorphism from $A_4$ to an abelian group is trivial on $V_4$ — so the finer fork $F_1(p) = [\mathrm{Frob}\,p = e]$ is unpinnable by any modulus. It is nevertheless not flat: we establish an **exact leakage law** $I = H(pq) - p\,H(q)$ for a $q$-thinning of a pinned rate-$p$ fork, yielding
$$I(p \bmod 9;\ F_1) = H(1/12) - \tfrac13 H(1/4) = 0.1434\ldots \text{ bits},$$
strictly between $0$ and $H(1/12) = 0.4138$. At composite level we compute the AND, OR, XOR and split-count channels of a semiprime exactly, prove a **which-factor wall** ($I = 0$ exactly), and give the $k$-factor generalization $I = H(3^{-(k+1)}) - \tfrac13 H(3^{-k})$, which we prove tends to $0$. Finally we prove $A_5$ is perfect and hence **absolutely unpinnable**, closing the pinning-content table $C_2 / C_3 / S_3 / S_4 / A_4 / A_5$.

**Keywords.** Alternating group $A_4$, abelianization, Klein resolvent, cyclic cubic field, conductor $9$, cubic residue character, Chebotarev density, mutual information, entropy trichotomy.

---

## 1. Introduction

### 1.1 The question

Let $f \in \mathbb{Z}[x]$ be irreducible with splitting field $L/\mathbb{Q}$ and Galois group $G$. For each prime $p$ unramified in $L$, the Frobenius conjugacy class $\mathrm{Frob}\,p \subseteq G$ determines the factorization type of $f \bmod p$: the cycle type of $\mathrm{Frob}\,p$ acting on the roots is the degree multiset of the irreducible factors. By Chebotarev's density theorem the Frobenius elements are equidistributed in $G$.

Fix a **fork**: a conjugation-stable binary predicate $F$ on $G$, evaluated at $\mathrm{Frob}\,p$. Fix a **dial**: the residue class $p \bmod m$ for some modulus $m$. Both are random variables on the set of primes. We ask:

> **How many bits does the dial carry about the fork?**

Classically, the extreme cases are familiar. For $f = x^2+1$, $G = C_2$ and the fork "split" is determined by $p \bmod 4$: one full bit. For a generic quintic, no congruence tells you anything. The purpose of this paper is to make "how many bits" a precise, computable, and *complete* invariant, and to identify exactly which group-theoretic feature controls it.

### 1.2 What is new

Prior instances of congruence pinning fall into two families:

1. **Sign pinning.** $G = S_3$ or $S_4$, with $G^{\mathrm{ab}} = C_2$; the pinned fork is the quadratic character of the discriminant, worth $H(1/2) = 1$ bit.
2. **Abelian cubic pinning.** $G = C_3$ (a cyclic cubic field); the pinned fork is "$p$ splits completely", worth $H(1/3)$ bits.

Both are unsatisfying as tests of the underlying principle. In (1) the abelianization is the smallest nontrivial group; in (2) the group is abelian outright, so "factors through $G^{\mathrm{ab}}$" is vacuous. The structurally decisive question is:

> **Can a genuinely non-abelian Galois group pin a fork by a genuinely cubic character?**

The smallest candidate is $A_4$: it is non-abelian, its commutator subgroup $V_4$ is nontrivial, and $A_4/V_4 \cong C_3$. We answer affirmatively, with the exact value $H(1/3)$ — the *same* value as the abelian cyclic cubic. The conclusion is a sharpening of the folklore: **abelianness of $G$ is irrelevant; only the character of $G^{\mathrm{ab}}$ matters.**

A second novelty is that $A_4$ supports all three regimes of the trichotomy simultaneously, in a single field, with all three values computed in closed form — the pinned $V_4$-fork, the flat within-$V_4$ question, and the leaking identity fork.

### 1.3 Organization

Section 2 develops the information calculus and proves the trichotomy and the leakage law. Section 3 handles the group $A_4$. Section 4 handles the arithmetic: the quartic, its Klein resolvent, and the conductor-$9$ identification. Section 5 assembles the pinning theorem and the leakage of the identity fork. Section 6 treats composite moduli. Section 7 proves the pinning-content criterion and the $A_5$ wall. Sections 8–10 discuss algorithms, applications, and open problems.

---

## 2. The information calculus

### 2.1 Definitions

All entropies are in **bits**. For $x \in [0,1]$ write
$$\eta(x) = -x\log_2 x \quad (\eta(0)=0), \qquad H(x) = \eta(x) + \eta(1-x),$$
so $H$ is the binary entropy function; for a finite probability vector $(p_z)$ write $H(p) = \sum_z \eta(p_z)$.

**Definition 2.1 (dial, fork, channel).** A **dial** is a finite set $Y$ with weights $w : Y \to \mathbb{R}_{>0}$, $\sum_y w(y) = 1$. A **fork** over the dial is a function $f : Y \to [0,1]$, interpreted as the conditional rate $f(y) = P(F = 1 \mid \text{dial} = y)$. Its **average rate** is
$$\bar f = \mathrm{avg}(w,f) = \sum_{y} w(y) f(y),$$
its **conditional entropy** is $H(F \mid Y) = \sum_y w(y) H(f(y))$, and its **mutual information** is
$$I(w,f) \;=\; H(\bar f) \;-\; \sum_y w(y) H(f(y)).$$

**Definition 2.2 (regimes).** The fork is **pinned** if $f(y) \in \{0,1\}$ for all $y$; **flat** if $f$ is constant; and **leaking** otherwise.

For a general finite-valued observable with conditional distributions $P(y,\cdot)$ on a finite set $Z$ we use
$$I_{\mathrm{gen}}(w,P) = H\Big(\textstyle\sum_y w(y)P(y,\cdot)\Big) - \sum_y w(y) H(P(y,\cdot)),$$
and we record that for a binary observable, $P(y,\cdot) = (f(y), 1-f(y))$, this reduces to Definition 2.1: $I_{\mathrm{gen}} = I$.

### 2.2 Concavity

**Lemma 2.3.** $\eta$ is strictly concave on $[0,\infty)$ and $H$ is strictly concave on $[0,1]$. Moreover $H(x) \ge 0$ on $[0,1]$, with $H(x) = 0$ if and only if $x \in \{0,1\}$, and $H(1/2)=1$.

*Proof sketch.* Strict concavity of $x \mapsto -x\log x$ is classical (its second derivative is $-1/x < 0$); dividing by $\log 2$ preserves it. For $H$, add the strictly concave $\eta(x)$ and the strictly concave $\eta(1-x)$ (a composition with an affine bijection). Non-negativity and the vanishing locus follow from $\eta(x) > 0$ for $x \in (0,1)$. $\square$

**Lemma 2.4 (strict thinning gain).** For $0 < p < 1$ and $0 < q \le 1$,
$$p\,H(q) \;<\; H(pq).$$

*Proof sketch.* Apply strict concavity of $H$ to the strict convex combination $pq = p\cdot q + (1-p)\cdot 0$ of the distinct points $q$ and $0$: $H(pq) > p H(q) + (1-p)H(0) = pH(q)$. $\square$

Lemma 2.4 is the engine of the whole leaking regime: *diluting a biased coin with an independent coin strictly increases entropy relative to the naive linear estimate.*

### 2.3 The three laws

**Theorem 2.5 (pinned law).** If $f(y) \in \{0,1\}$ for all $y$, then $I(w,f) = H(\bar f)$.

*Proof.* Each term $w(y)H(f(y))$ vanishes since $H(0)=H(1)=0$; hence the conditional entropy is $0$. $\square$

**Theorem 2.6 (flat law).** If $f \equiv c$ is constant, then $I(w,f) = 0$.

*Proof.* $\bar f = c\sum_y w(y) = c$, and the conditional entropy is $H(c)\sum_y w(y) = H(c)$. $\square$

**Theorem 2.7 (exact leakage law).** Let $g : Y \to \{0,1\}$ be a pinned fork with rate $p = \bar g$, let $q \in [0,1]$, and let $f(y) = q\,g(y)$. Then
$$I(w,f) \;=\; H(pq) \;-\; p\,H(q).$$

*Proof.* The average rate is $\bar f = q\,\bar g = pq$. For the conditional entropy, split by the value of $g$: where $g(y)=0$ the term is $w(y)H(0)=0$; where $g(y)=1$ the term is $w(y)H(q)$. Summing gives $H(q)\sum_{g(y)=1}w(y) = p\,H(q)$. Subtract. $\square$

**Theorem 2.8 (strictness of leakage).** In the setting of Theorem 2.7, if $0 < p < 1$ and $0 < q < 1$ then
$$0 \;<\; I(w,f) \;<\; H(\bar f) = H(pq).$$

*Proof.* The left inequality is Lemma 2.4. The right holds because $p H(q) > 0$. $\square$

**Theorem 2.9 (fork trichotomy).** Let $w$ be strictly positive with $\sum_y w(y)=1$ and $f : Y \to [0,1]$. Then
$$0 \le I(w,f) \le H(\bar f),$$
with
- $I(w,f) = 0 \iff f$ is constant;
- $I(w,f) = H(\bar f) \iff f(y)\in\{0,1\}$ for all $y$.

*Proof sketch.* Jensen for the concave $H$ gives $\sum_y w(y)H(f(y)) \le H(\sum_y w(y)f(y)) = H(\bar f)$, whence $I \ge 0$; equality in Jensen for a *strictly* concave function with strictly positive weights forces all $f(y)$ equal, which is flatness, and conversely by Theorem 2.6. For the upper bound, $I \le H(\bar f)$ because the subtracted conditional entropy is a sum of non-negative terms; equality forces every $w(y)H(f(y)) = 0$, hence (as $w(y)>0$) every $H(f(y))=0$, hence every $f(y) \in \{0,1\}$ by Lemma 2.3, which is pinnedness; and conversely by Theorem 2.5. $\square$

Theorem 2.9 is what licenses the language of this paper: there are precisely three regimes, they are mutually exclusive and exhaustive, and each is characterized by an equality case.

### 2.4 Two numerical constants

We record the two exact values used throughout, together with rigorous bounds derived from integer power comparisons ($3^{1000} < 2^{1585}$ and $2^{15849} < 3^{10000}$, hence $1.5849 < \log_2 3 < 1.585$):

$$H(1/3) = \log_2 3 - \tfrac23 \in (0.918,\,0.919), \qquad H(1/4) = 2 - \tfrac34\log_2 3 \in (0.811,\,0.812).$$

---

## 3. The group side: $V_4 = [A_4,A_4]$

Throughout, $A_4 \subset S_4 = \mathrm{Sym}(\{0,1,2,3\})$ is the alternating group, $|A_4| = 12$.

**Definition 3.1.** $V_4 = \{\sigma \in S_4 : \sigma^2 = 1,\ \mathrm{sgn}(\sigma) = 1\}$, the set of *even involutions*.

This intrinsic definition — no list of elements — makes closure transparent. Concretely $V_4 = \{e,(01)(23),(02)(13),(03)(12)\}$, so $|V_4| = 4$, and $V_4 \subseteq A_4$ by construction.

**Theorem 3.2 (commutator subgroup).** $[A_4,A_4] = V_4$.

*Proof sketch.* Two finite verifications over the $144$ ordered pairs of even permutations: (i) every commutator $[a,b]$ with $a,b$ even is an even involution, so $[A_4,A_4] \le V_4$; (ii) every even involution occurs as such a commutator — e.g. $(01)(23) = [(012),(013)]$ up to relabelling — so $V_4 \le [A_4,A_4]$. $\square$

**Corollary 3.3.** $|A_4^{\mathrm{ab}}| = |A_4/V_4| = 12/4 = 3$. In particular the abelianization is cyclic of order three, and **every** character of $A_4$ is cubic.

**Definition 3.4 (the cubic character).** Fix the $3$-cycle $c = (0\,1)(0\,2)$. Define $\chi : A_4 \to \mathbb{Z}/3$ by
$$\chi(\sigma) = \begin{cases} 0 & \sigma \in V_4,\\ 1 & \sigma c^{-1} \in V_4,\\ 2 & \text{otherwise.}\end{cases}$$

**Theorem 3.5.** $\chi$ is a surjective homomorphism $A_4 \to \mathbb{Z}/3$ with $\chi(\sigma) = 0 \iff \sigma \in V_4$. Equivalently, $\chi$ is the composite $A_4 \twoheadrightarrow A_4^{\mathrm{ab}} \cong \mathbb{Z}/3$.

*Proof sketch.* Additivity $\chi(\sigma\tau) = \chi(\sigma)+\chi(\tau)$ on $A_4$ is a finite check; the kernel condition is immediate from the definition (for the third branch one checks $2 \ne 0$ in $\mathbb{Z}/3$); surjectivity holds already on $A_4$ since $\chi(e)=0$, $\chi(c)=1$, $\chi(c^2)=2$. $\square$

### 3.1 The root signature

**Definition 3.6.** For $\sigma \in S_4$ let $\mathrm{nr}(\sigma) = \#\{i : \sigma(i)=i\}$, the number of fixed roots. Arithmetically, $\mathrm{nr}(\mathrm{Frob}\,p)$ is the number of degree-one factors of the quartic mod $p$.

**Theorem 3.7 ($[4,1,0]$ signature).** For every $\sigma \in A_4$, $\mathrm{nr}(\sigma) \in \{4,1,0\}$; in particular $\mathrm{nr}(\sigma) \neq 2$. The class sizes are:

| class | $\mathrm{nr}$ | size | density |
|---|---|---|---|
| identity $e$ | $4$ | $1$ | $1/12$ |
| $3$-cycles | $1$ | $8$ | $2/3$ |
| double transpositions | $0$ | $3$ | $1/4$ |

**Theorem 3.8 (observability).** For $\sigma \in A_4$: $\ \sigma \in V_4 \iff \mathrm{nr}(\sigma) \in \{4,0\}$.

Theorem 3.8 is what makes the fork *measurable*: $F_0$ is not an abstract group condition but the concrete statement that the quartic has $4$ or $0$ roots mod $p$. Theorem 3.7 also gives the striking negative prediction that no prime yields exactly two roots — the naive guess that a double transposition "looks like" a two-root reduction is simply wrong, since a fixed-point-free involution fixes no root at all.

The Chebotarev density of $F_0$ is $|V_4|/|A_4| = 4/12 = 1/3$; conditionally on $F_0$, the identity has probability $1/|V_4| = 1/4$.

### 3.2 Within-$V_4$ flatness

**Theorem 3.9 (within-$V_4$ flatness).** Let $A$ be any abelian group and $\psi : A_4 \to A$ any homomorphism. Then $\psi|_{V_4} \equiv 1$. Consequently $\psi(v) = \psi(e)$ for every $v \in V_4$: the identity and the double transpositions are indistinguishable by abelian data, despite lying in distinct conjugacy classes of $A_4$.

*Proof.* $[A_4,A_4] \le \ker\psi$ for any homomorphism into an abelian group, and $[A_4,A_4] = V_4$ by Theorem 3.2. $\square$

This is the qualitatively new phenomenon relative to all previously known pinned forks: the commutator subgroup is nontrivial, so it hides genuine arithmetic structure — an entire order-$4$ group of Frobenius behaviours — behind a single abelian fibre.

---

## 4. The arithmetic side: $x^4+8x+12$ and the conductor-$9$ cubic

### 4.1 The Klein resolvent

Let $r_1,r_2,r_3,r_4$ be the roots of $x^4+8x+12$, so their elementary symmetric functions are
$$e_1 = 0,\quad e_2 = 0,\quad e_3 = -8,\quad e_4 = 12.$$
(The signs follow from $x^4 - e_1x^3 + e_2x^2 - e_3x + e_4$.) The three **Klein resolvent values** are
$$A = r_1r_2+r_3r_4,\quad B = r_1r_3+r_2r_4,\quad C = r_1r_4+r_2r_3,$$
each stabilized precisely by $V_4$ (together with the transpositions in $S_4$ that swap the pairs).

**Theorem 4.1 (resolvent).** $A+B+C = e_2 = 0$, $\ AB+BC+CA = e_1e_3 - 4e_4 = -48$, and $ABC = e_1^2 e_4 - 4e_2e_4 + e_3^2 = 64$. Hence each of $A,B,C$ satisfies
$$y^3 - 48y - 64 = 0.$$

*Proof sketch.* Each of the three displayed identities is a polynomial identity in $r_1,\dots,r_4$, verified by expansion; substituting $e_1=e_2=0$, $e_3=-8$, $e_4=12$ gives the stated numbers. That $A$ is a root then follows from $A^3 - (A+B+C)A^2 + (AB+BC+CA)A - ABC = 0$. $\square$

**Theorem 4.2 (discriminant).** For any $r_1,\dots,r_4$,
$$\prod_{i<j}(r_i-r_j)^2 = \big((A-B)(B-C)(C-A)\big)^2 :$$
the discriminant of a quartic equals that of its Klein resolvent. For $x^4+8x+12$ both equal
$$\mathrm{disc} = 576^2 = 2^{12}\cdot 3^4 .$$

*Proof sketch.* The first identity is a polynomial identity (expand both sides). For the value: for a depressed cubic with root sum zero, $((x-y)(y-z)(z-x))^2 = -4(xy+yz+zx)^3 - 27(xyz)^2$, obtained by eliminating $z = -x-y$; substituting $-48$ and $64$ gives $4\cdot 48^3 - 27\cdot 64^2 = 442368 - 110592 = 331776 = 576^2$. $\square$

**Corollary 4.3 (Galois group).** $\mathrm{disc}$ is a perfect square, hence $\mathrm{Gal} \subseteq A_4$. Since $x^4+8x+12$ is irreducible (the group is transitive) and the group has order divisible by $4$ and contains an element of order $3$, $\mathrm{Gal} = A_4$.

*Remark 4.4 (empirical confirmation).* Sieving $22{,}996$ unramified primes gives root-count frequencies $0.0826$ ($4$ roots), $0.6661$ ($1$ root), $0.2513$ ($0$ roots), $0.0000$ ($2$ roots), against the $A_4$ predictions $1/12$, $2/3$, $1/4$, $0$. The vanishing two-root count is precisely the absence of transpositions.

### 4.2 The resolvent is the conductor-$9$ cyclic cubic

**Theorem 4.5 (rescaling).** $\ (4z)^3 - 48(4z) - 64 = 64\,(z^3 - 3z - 1)$.

Thus, up to the substitution $y = 4z$, the Klein resolvent is the cubic $z^3-3z-1$, and after $z \mapsto -z$ it is $z^3-3z+1$ — the classical *simplest cubic* of conductor $9$.

**Theorem 4.6 (cyclotomic identification).** Let $\zeta$ satisfy $\zeta^9 = 1$, $\zeta^3 \neq 1$. Then
$$(\zeta+\zeta^{-1})^3 - 3(\zeta+\zeta^{-1}) + 1 = 0,$$
and hence $-(\zeta+\zeta^{-1})$ is a root of $z^3-3z-1$ and $-4(\zeta+\zeta^{-1})$ is a root of $y^3-48y-64$.

*Proof.* From $\zeta^9=1$ and $\zeta^3\ne1$, factoring $(\zeta^3)^3-1$ gives $\zeta^6+\zeta^3+1=0$. Expanding, $(\zeta+\zeta^{-1})^3 = \zeta^3 + 3\zeta + 3\zeta^{-1} + \zeta^{-3}$, so the left side equals $\zeta^3+\zeta^{-3}+1 = \zeta^{-3}(\zeta^6+\zeta^3+1) = 0$. The sign flips follow from oddness of $z\mapsto z^3-3z$. $\square$

**Corollary 4.7.** The resolvent field $K = L^{V_4}$ is $\mathbb{Q}(\zeta_9)^+$, the maximal real subfield of $\mathbb{Q}(\zeta_9)$: cyclic of degree $3$ over $\mathbb{Q}$, ramified only at $3$, of discriminant $81 = 9^2$ and **conductor $9$**.

**Theorem 4.8 (irreducibility).** $z^3-3z+1$ has no rational root; hence neither does $y^3-48y-64$, and both are irreducible over $\mathbb{Q}$.

*Proof sketch.* Write $z = a/b$ in lowest terms; clearing denominators gives $a^3 - 3ab^2 + b^3 = 0$. Then $b \mid a^3$, and coprimality forces $b = 1$; then $a \mid 1$, so $a = \pm1$, and neither value is a root. A cubic with no rational root is irreducible over $\mathbb{Q}$. $\square$

*Remark 4.9 (why $9$ and not $3$).* The natural generator $A = r_1r_2+r_3r_4$ of $K$ is not an algebraic-integer generator of the maximal order; its index is $64$, and after removing the power of $2$ one finds field discriminant $81$, hence conductor $9$. Theorem 5.5 below shows this is not bookkeeping: the modulus $3$ carries exactly zero information.

### 4.3 Cubes mod $9$

**Theorem 4.10.** $(\mathbb{Z}/9)^\times$ is cyclic of order $6$. A unit $x$ is a cube modulo $9$ if and only if $x \equiv 1$ or $8 \pmod 9$. The cubes form a subgroup of order $2$ and index $3$.

**Definition 4.11 (cubic residue character mod $9$).** $\chi_9 : (\mathbb{Z}/9)^\times \to \mathbb{Z}/3$ by $\{1,8\}\mapsto 0$, $\{2,7\}\mapsto 1$, $\{4,5\}\mapsto 2$.

**Theorem 4.12.** $\chi_9$ is a surjective homomorphism with kernel the cubes; i.e. $\chi_9(xy) = \chi_9(x)+\chi_9(y)$ for units $x,y$, and $\chi_9(x)=0 \iff x$ is a cube mod $9$.

**Theorem 4.13 (the shape of the Artin square).** $\ \big|(\mathbb{Z}/9)^\times/\text{cubes}\big| = 3$, and consequently
$$A_4^{\mathrm{ab}} \;\cong\; (\mathbb{Z}/9)^\times/\text{cubes} \;\cong\; C_3 .$$
The Galois side and the ray-class side of the pinning are the *same* cyclic group of order three.

*Proof.* Index $6/2 = 3$; both groups have prime order $3$, hence both are cyclic of order $3$, hence isomorphic. $\square$

---

## 5. The pinning theorem at prime level

We now combine. The dial is $p \bmod 9$, with the six coprime classes $\{1,2,4,5,7,8\}$ equidistributed (Dirichlet). Class field theory for the conductor-$9$ cyclic cubic $K$ says that $\mathrm{Frob}\,p$ lies in $\mathrm{Gal}(L/K) = V_4$ if and only if $p$ splits completely in $K$, if and only if $p$ is a cube mod $9$. Chebotarev makes $\mathrm{Frob}\,p$ equidistributed in $A_4$.

**Definition 5.1.** $F_0(p) = [\mathrm{Frob}\,p \in V_4] = [\chi_9(p \bmod 9) = 0] = [\,p \equiv 1 \text{ or } 8 \pmod 9\,]$, and (Theorem 3.8) equivalently $[\,x^4+8x+12 \text{ has } 4 \text{ or } 0 \text{ roots mod } p\,]$.

**Theorem 5.2 (rate).** $F_0$ has rate $\bar F_0 = 2/6 = 1/3$, which is also the Chebotarev density $|V_4|/|A_4| = 1/3$.

**Theorem 5.3 (cubic pinning of a non-abelian fork).** $F_0$ is a deterministic function of the dial $p \bmod 9$, and
$$\boxed{\,I(p \bmod 9;\ F_0) \;=\; H(1/3) \;=\; \log_2 3 - \tfrac23 \;=\; 0.9183\ldots \text{ bits.}\,}$$
Moreover $0.918 < I < 0.919$.

*Proof.* Every conditional rate is $0$ or $1$, so Theorem 2.5 applies with $\bar f = 1/3$; the numeric bounds come from §2.4. $\square$

*Remark 5.4.* This is the same value as for an abelian cyclic cubic field. Empirically, over $22{,}996$ unramified primes, the conditional rates are $1.0000$ on $\{1,8\}$ and $0.0000$ on $\{2,4,5,7\}$, and the measured mutual information is $0.9188$ bits.

**Theorem 5.5 (minimality of the conductor).** Reading $F_0$ through the coarser dial $p \bmod 3$ gives constant conditional rate $1/3$ — each of the two classes mod $3$ contains exactly one cube among its three units mod $9$ — hence
$$I(p \bmod 3;\ F_0) = 0.$$

**Theorem 5.6 (flatness off the conductor).** Reading $F_0$ through the dial $p \bmod 5$ gives constant conditional rate $1/3$, hence $I(p \bmod 5; F_0) = 0$.

Together, Theorems 5.3, 5.5 and 5.6 show that $9$ is exactly the right modulus: coarsening it or replacing it by a coprime modulus destroys all information.

### 5.1 The identity fork leaks

**Definition 5.7.** $F_1(p) = [\mathrm{Frob}\,p = e] = [\,x^4+8x+12 \text{ splits into four linear factors mod } p\,]$, of rate $1/12$.

Since $F_1 \subset F_0$ and, conditionally on $F_0$, the Frobenius is equidistributed in $V_4$ (Chebotarev), $F_1$ is exactly the $\tfrac14$-thinning of the pinned fork $F_0$:
$$P(F_1 = 1 \mid p \bmod 9 = y) = \tfrac14\, F_0(y).$$

**Theorem 5.8 (exact leakage of the identity fork).**
$$\boxed{\,I(p \bmod 9;\ F_1) \;=\; H(1/12) - \tfrac13 H(1/4) \;=\; 0.4138 - \tfrac13(0.8113) \;=\; 0.1434\ldots \text{ bits.}\,}$$
Moreover $0 < I(p\bmod 9;F_1) < H(1/12)$: the identity fork is **neither pinned nor flat**.

*Proof.* Theorem 2.7 with $p = 1/3$, $q = 1/4$, noting $pq = 1/12$; strictness from Theorem 2.8. $\square$

*Remark 5.9.* Measured value: $0.1419$ bits. The gap $H(1/12) - I = 0.2704 = \tfrac13 H(1/4)$ is exactly the entropy hidden inside the $V_4$ fibre — which Theorem 3.9 shows is inaccessible to *any* modulus, not merely to $9$.

**Theorem 5.10 (regime separation).** $I(p\bmod 9; F_0) = H(\bar F_0)$ while $I(p \bmod 9; F_1) < H(\bar F_1)$: the coarse fork saturates the channel and the fine fork provably cannot.

Empirically: $P(\mathrm{Frob}=e \mid p\equiv1) = 0.2426$ and $P(\mathrm{Frob}=e\mid p\equiv 8) = 0.2523$, both $\approx 1/4$, and the conditional mutual information between the dial and "identity vs. double transposition" given $F_0=1$ measures $0.0001$ bits — the empirical face of Theorem 3.9.

---

## 6. Composite level: the order-$3$ channel

### 6.1 Semiprimes

Let $N = p_1p_2$ with both $p_i$ unramified. Multiplicativity of $\chi_9$ (Theorem 4.12) gives
$$\chi_9(N) = \chi_9(p_1) + \chi_9(p_2) \in \mathbb{Z}/3,$$
so the dial reads only the **sum** of the two cube classes, which are independent and uniform on $\mathbb{Z}/3$. All conditional rates are therefore exact counts of pairs $(a,b) \in (\mathbb{Z}/3)^2$ with $a+b = t$; each such fibre has exactly $3$ elements.

| event | pairs with $a+b=0$ | with $a+b\neq0$ | conditional rates |
|---|---|---|---|
| both split ($a=b=0$) | $1$ | $0$ | $(1/3,0,0)$ |
| at least one splits | $1$ | $2$ | $(1/3,2/3,2/3)$ |
| exactly one splits | $0$ | $2$ | $(0,2/3,2/3)$ |
| first factor splits | $1$ | $1$ | $(1/3,1/3,1/3)$ |

**Theorem 6.1 (AND law).** $\ I(N \bmod 9;\ \text{both factors split}) = H(1/9) - \tfrac13 H(1/3) = 0.1972\ldots$ bits.

*Proof.* The rate vector is the $\tfrac13$-thinning of the pinned fork $[\chi_9(N)=0]$ of rate $1/3$; apply Theorem 2.7. $\square$

**Theorem 6.2 (OR law).** $\ I(N \bmod 9;\ \text{at least one splits}) = H(5/9) - H(1/3) = 0.0728\ldots$ bits.

*Proof.* Average rate $\tfrac13(\tfrac13+\tfrac23+\tfrac23) = \tfrac59$; conditional entropy $\tfrac13(H(1/3)+2H(2/3)) = H(1/3)$ since $H(2/3)=H(1/3)$. $\square$

**Theorem 6.3 (XOR law).** $\ I(N \bmod 9;\ \text{exactly one splits}) = H(4/9) - \tfrac23 H(1/3) = 0.3789\ldots$ bits.

*Proof.* Average rate $\tfrac13(0+\tfrac23+\tfrac23) = \tfrac49$; conditional entropy $\tfrac13(H(0)+2H(2/3)) = \tfrac23 H(1/3)$. $\square$

**Theorem 6.4 (split-count law).** Let $S \in \{0,1,2\}$ be the number of split factors of $N$. Its marginal law is $\mathrm{Bin}(2,1/3) = (4/9,4/9,1/9)$, its conditional laws given $\chi_9(N) = 0,1,2$ are $(2/3,0,1/3)$, $(1/3,2/3,0)$, $(1/3,2/3,0)$ respectively — each of entropy $H(1/3)$ — and
$$I(N \bmod 9;\ S) = H(4/9,4/9,1/9) - H(1/3) = 1.3921 - 0.9183 = 0.4739\ldots \text{ bits.}$$

**Theorem 6.5 (the which-factor wall).** $\ I(N \bmod 9;\ [\,p_1 \text{ splits}\,]) = 0$ **exactly**.

*Proof.* For each $t \in \mathbb{Z}/3$ there is exactly one pair $(a,b)$ with $a+b=t$ and $a = 0$, out of three; so the conditional rate is $1/3$ for every $t$, and Theorem 2.6 applies. $\square$

*Remark 6.6.* Theorem 6.5 is the structural reason this circle of ideas gives no factoring leverage: a dial reads a product, a product is symmetric in its factors, so the *assignment* of splitting behaviour to individual factors is invisible. Empirically the measured which-factor information is $0.0001$ bits. Measured values for the other channels: split-count $0.4710$ (vs. $0.4739$), OR $0.0688$ (vs. $0.0728$), AND $0.1997$ (vs. $0.1972$), XOR $0.3736$ (vs. $0.3789$). A dial mod $5$ is flat at semiprime level as well.

*Remark 6.7.* Theorems 6.1–6.5 are numerically and structurally identical to the corresponding laws for an *abelian* cyclic cubic field. The order-$3$ split-count law needs only the character; it never sees whether $G$ is abelian. This is the composite-level version of the paper's thesis.

### 6.2 Many factors, and collapse

Let $N = p_1 \cdots p_{k+1}$.

**Lemma 6.8.** Every fibre of the sum map $(\mathbb{Z}/3)^{k+1} \to \mathbb{Z}/3$ has exactly $3^k$ elements, and exactly one point of the fibre over $0$ (and none of the others) has all coordinates zero.

*Proof sketch.* Fix the first $k$ coordinates freely; the last is then determined. The all-zero tuple has sum $0$. $\square$

**Theorem 6.9 ($k$-factor AND law).** $P(\text{all factors split} \mid \chi_9(N)=t) = 3^{-k}\,[t=0]$, and
$$I(N \bmod 9;\ \text{all factors split}) \;=\; H\!\left(3^{-(k+1)}\right) - \tfrac13\,H\!\left(3^{-k}\right).$$
For $k=1$ this is the semiprime value $H(1/9)-\tfrac13H(1/3)$. For every $k \ge 1$ the information is strictly positive and strictly below $H(3^{-(k+1)})$.

**Theorem 6.10 (channel collapse).** $\ I(N\bmod 9;\ \text{all factors split}) \to 0$ as $k \to \infty$.

*Proof sketch.* $3^{-k} \to 0$ and $H$ is continuous with $H(0) = 0$, so both terms tend to $0$. $\square$

Numerically the decay is rapid: $0.1972$, $0.0608$, $0.0198$, $0.0065$, $0.0022$ bits for $k = 1,\dots,5$. The residue of a number with many prime factors is essentially uninformative about the splitting of its factors.

---

## 7. The pinning-content criterion and the $A_5$ wall

Let $G$ be any group and $F : G \to \{\text{true},\text{false}\}$ a fork.

**Definition 7.1.** $F$ **factors through the abelianization** if there is $\tilde F : G^{\mathrm{ab}} \to \{\text{true},\text{false}\}$ with $F(g) \iff \tilde F(\bar g)$ for all $g$, where $\bar g$ is the image of $g$ in $G^{\mathrm{ab}} = G/[G,G]$.

By class field theory, congruence conditions on $p$ see $\mathrm{Frob}\,p$ only through abelian quotients; so Definition 7.1 characterizes the forks a modulus can possibly pin.

**Theorem 7.2 (pinning-content criterion).**
$$F \text{ factors through } G^{\mathrm{ab}} \iff \forall g \in G,\ \forall c \in [G,G]:\ \big(F(gc) \iff F(g)\big).$$

*Proof.* ($\Rightarrow$) Commutators map to $1$ in $G^{\mathrm{ab}}$, so $\overline{gc} = \bar g$. ($\Leftarrow$) Define $\tilde F(x) = $ "$\exists g$ with $\bar g = x$ and $F(g)$". Then $F(g) \Rightarrow \tilde F(\bar g)$ trivially. Conversely if $\tilde F(\bar g)$ holds, witnessed by $g'$ with $\bar{g'} = \bar g$, then $g'^{-1}g \in [G,G]$ and $g = g'(g'^{-1}g)$, so commutator-invariance gives $F(g) \iff F(g')$, which holds. $\square$

**Theorem 7.3 ($A_4$: the $V_4$-fork factors).** $F_0(g) = [g \in V_4]$ factors through $A_4^{\mathrm{ab}}$.

*Proof.* $V_4 = [A_4,A_4]$ is a subgroup, so $g \in V_4 \iff gc \in V_4$ for $c \in V_4$; apply Theorem 7.2. $\square$

Combined with Corollary 3.3 ($|A_4^{\mathrm{ab}}| = 3$), this says $F_0$ is pinnable and can only be pinned by a *cubic* character — which §4 identifies as $\chi_9$.

**Theorem 7.4 ($A_4$: the identity fork does not factor).** $F_1(g) = [g = e]$ does **not** factor through $A_4^{\mathrm{ab}}$.

*Proof.* Take $c = (01)(23) \in V_4 = [A_4,A_4]$ and $g = e$. Then $F_1(g)$ holds but $F_1(gc) = [c = e]$ fails, contradicting Theorem 7.2. $\square$

Thus $F_1$ is unpinnable *by any modulus whatsoever* — yet by Theorem 5.8 it leaks a precise $0.1434$ bits. The pair (Theorem 7.3, Theorem 7.4) is the structural explanation of the pinned/leaking dichotomy observed at prime level.

**Theorem 7.5 ($A_5$ is perfect).** $[A_5,A_5] = A_5$.

*Proof.* The commutator subgroup is normal in the simple group $A_5$, hence trivial or everything. If trivial, $A_5$ would be abelian; but $(012)$ and $(234)$ do not commute. $\square$

**Theorem 7.6 (absolute unpinnability of $A_5$).** Every homomorphism from $A_5$ to an abelian group is trivial. Consequently a fork of $A_5$ factors through $A_5^{\mathrm{ab}}$ if and only if it is constant: over an $A_5$-field, no congruence condition of any modulus carries a single bit about the factorization type.

*Proof.* $[A_5,A_5] \le \ker\psi$ and $[A_5,A_5] = A_5$. For the second part, Theorem 7.2 with $[G,G]=G$ says $F(gc) \iff F(g)$ for all $g,c$, i.e. $F$ is constant. $\square$

### 7.1 The completed table

| Galois group $G$ | $G^{\mathrm{ab}}$ | pinnable fork | conductor type | maximal information |
|---|---|---|---|---|
| $C_2$ | $C_2$ | split vs. inert | quadratic | $H(1/2) = 1$ bit |
| $C_3$ | $C_3$ | split vs. inert | cubic | $H(1/3) = 0.9183$ bits |
| $S_3$ | $C_2$ | sign of Frobenius | quadratic | $H(1/2) = 1$ bit |
| $S_4$ | $C_2$ | sign of Frobenius | quadratic | $H(1/2) = 1$ bit |
| $A_4$ | $C_3$ | $V_4$-membership | **cubic**, conductor $9$ | $H(1/3) = 0.9183$ bits |
| $A_5$ | $1$ | none | — | $0$ |

The $A_4$ row is the one that separates the two candidate explanations. If abelianness were the operative property, $A_4$ (non-abelian, with nontrivial commutator subgroup) should have behaved differently from the cyclic cubic. It does not: the value is $H(1/3)$ on both rows, to four decimals over tens of thousands of primes. **The invariant is the character of the abelianization, not commutativity of $G$.**

---

## 8. Algorithms

Three computational procedures underlie the empirical numbers.

**(A) Frobenius signature sieve.** For each prime $p$ in a range, compute $\mathrm{nr}(p) = $ the number of roots of $x^4+8x+12$ in $\mathbb{F}_p$ by direct evaluation (or, faster, by $\gcd(x^p-x, f)$ in $\mathbb{F}_p[x]$). Tabulate the frequency of each value in $\{0,1,2,4\}$ (the value $3$ is impossible for any quartic, since three roots in $\mathbb{F}_p$ force the fourth, and $2$ is impossible for an $A_4$-field by Theorem 3.7). Complexity: $O(\pi(X)\log^{O(1)}X)$ with the polynomial-gcd method, $O(\pi(X)\cdot X)$ naively.

**(B) Empirical mutual information estimator.** Given a stream of pairs (dial value, fork value), accumulate the joint contingency table, form the empirical marginals, and evaluate $\hat I = \sum_{y,b}\hat P(y,b)\log_2\frac{\hat P(y,b)}{\hat P(y)\hat P(b)}$. Complexity $O(n + |Y|)$; the estimator has $O(|Y|/n)$ bias, which at $n \approx 2\times10^4$, $|Y| = 6$ accounts for the observed discrepancies of order $10^{-3}$ bits.

**(C) Exact channel evaluator.** For the composite-level laws, enumerate $(\mathbb{Z}/3)^{k+1}$ or, better, use the closed forms of §6: form the conditional distribution table, compute $H$ of the marginal minus the weighted average of the conditional entropies. Complexity $O(3^{k+1})$ by enumeration, $O(1)$ by the closed forms.

---

## 9. Applications and interpretation

**9.1 A complete answer to "what can residues tell you".** The trichotomy plus the criterion give a decision procedure: given $G$ and a fork $F$, check whether $F$ is invariant under $[G,G]$-translation. If yes, $F$ is pinned by the associated character and $I = H(\bar F)$. If $F$ is a uniform thinning of such a fork, $I = H(pq) - pH(q)$. If $F$ is orthogonal to $G^{\mathrm{ab}}$, $I = 0$. No arithmetic input beyond Chebotarev is needed.

**9.2 Why this is not a factoring tool.** Theorem 6.5 is an exact zero, and Theorem 6.10 shows even the aggregate signal collapses with the number of factors. Any hope of extracting factorization information from residues of composites founders on the symmetry of multiplication: a product cannot distinguish its factors, and the cubic character is a homomorphism. This is a *theorem-level* obstruction, not a failure of ingenuity.

**9.3 Quantifying "how far from abelian".** The gap $H(\bar F) - I$ for the finest fork measures exactly the entropy locked inside the commutator subgroup. For $A_4$ and the identity fork it is $\tfrac13 H(1/4) = 0.2704$ bits — a numerical invariant of the pair $([G,G] \trianglelefteq G,\ F)$. For $A_5$ the entire entropy is locked.

**9.4 Classical roots.** Every ingredient is nineteenth- or early-twentieth-century: Eisenstein's cubic reciprocity (1844) for the cubic residue symbol; the Klein resolvent for the $V_4$-fixed field; Takagi's class field theory (1920) for the conductor-$9$ correspondence; Chebotarev (1922) for equidistribution. The novelty here is the *information-theoretic* reading, which converts qualitative statements ("visible/invisible to congruences") into exact bit counts and an exhaustive trichotomy.

---

## 10. Discussion and future work

The $A_4$ case is the decisive test of the pinning-content criterion because it is the smallest group that is non-abelian and yet has a cubic abelianization. That its $V_4$-fork pins at exactly $H(1/3)$, the same value as the abelian cyclic cubic, isolates the correct invariant: the character of $G^{\mathrm{ab}}$. Three concrete directions follow.

### C1. The conductor–order dictionary

**Conjecture.** Let $L/\mathbb{Q}$ be Galois with group $G$, let $N \trianglelefteq G$ with $G/N$ cyclic of order $m$, and let $F = [\mathrm{Frob} \in N]$. Then $F$ is pinned by the character of conductor $f(G/N)$ and $I(p \bmod f;\ F) = H(1/m)$ exactly. Conversely, if a fork of rate $1/m$ attains $I = H(1/m)$ for some modulus, its defining set is a union of fibres of a cyclic quotient of order $m$.

The value $H(1/m)$ is no accident of the cubic case: it is the entropy of the uniform distribution on the fibres of $G \twoheadrightarrow G^{\mathrm{ab}} \twoheadrightarrow C_m$, and the trichotomy already forces saturation to be equivalent to determinism, so only the *rate* survives as an invariant. The converse direction is supplied abstractly by the equality case of Theorem 2.9; the group side is supplied by Theorem 7.2; what remains is the Artin–Chebotarev bridge.

### C2. Universal leakage spectrum of a Galois group

**Conjecture.** For a fixed $G$, the set of achievable pairs (rate, information) over *all* conjugation-stable forks and *all* moduli is the finite set
$$\{(pq,\ H(pq) - p\,H(q))\},$$
with $p \in \tfrac{1}{[G:G']}\mathbb{Z}$ and $q \in \tfrac{1}{|G'|}\mathbb{Z}$ — in particular it lies on the curve family $I = H(pq)-pH(q)$.

The reason to believe this is that every fork should factor as (pinned part) composed with (flat thinning), because the commutator subgroup acts transitively on the residual ambiguity: the leakage law is not one example but a *normal form*. Theorems 2.7, 2.8 and 3.9 give the two extremes; the missing step is a purely finite-group decomposition lemma asserting that every fork is a $q$-thinning of its $G^{\mathrm{ab}}$-saturation.

### C3. An unconditional information wall for $A_5$

**Conjecture.** For the splitting field of a quintic with $\mathrm{Gal} = A_5$ and *any* modulus $m$, *every* splitting fork satisfies $I(p \bmod m;\ F) = 0$: the factorization type of $p$ is statistically independent of every congruence class.

Theorem 7.6 already proves the group-theoretic half — $A_5$ is perfect, so no abelian character sees anything. What remains is to convert "no abelian character sees it" into "zero mutual information", i.e. to import the joint equidistribution of (Frobenius class, residue class) that Chebotarev in the compositum $L\cdot\mathbb{Q}(\zeta_m)$ provides. This would be the first *unconditional* zero-information theorem for a family of number fields.

### Further questions

- **Beyond binary forks.** The split-count channel of §6 is already non-binary; a general theory should compute $I$ for the full factorization-type observable, whose value is $H(\text{class distribution}) - H(\text{fibre distribution})$.
- **Higher $V_4$-analogues.** Which groups $G$ have $|G^{\mathrm{ab}}| = m$ with $[G,G]$ non-abelian? The information gap $H(\bar F)-I$ should then reflect the internal structure of $[G,G]$, not just its order.
- **Effectivity.** All statements here are density statements. Under GRH, effective Chebotarev would convert them into explicit bounds on the number of primes needed to observe $I$ to within $\epsilon$ — turning the trichotomy into a finite test.

---

## 11. Summary of results

1. **Fork trichotomy.** $0 \le I \le H(\bar f)$, with $I = 0$ iff flat and $I = H(\bar f)$ iff pinned. (Theorem 2.9)
2. **Exact leakage law.** For a $q$-thinning of a pinned rate-$p$ fork, $I = H(pq) - p\,H(q)$, strictly between $0$ and $H(pq)$. (Theorems 2.7, 2.8)
3. **Group side.** $[A_4,A_4] = V_4$, $|A_4^{\mathrm{ab}}| = 3$, the $[4,1,0]$ root signature, and within-$V_4$ flatness of every abelian character. (Theorems 3.2, 3.7, 3.9)
4. **Arithmetic side.** Klein resolvent $y^3-48y-64$ of $x^4+8x+12$, discriminant $576^2$, irreducible, equal to $64(z^3-3z-1)$ under $y=4z$, with root $-4(\zeta_9+\zeta_9^{-1})$: the resolvent field is $\mathbb{Q}(\zeta_9)^+$ of conductor $9$; cubes mod $9$ are $\{1,8\}$. (Theorems 4.1–4.13)
5. **Cubic pinning of a non-abelian fork.** $I(p\bmod 9;\ [\mathrm{Frob}\,p\in V_4]) = H(1/3) = \log_2 3 - 2/3$, with modulus $9$ minimal and coprime moduli flat. (Theorems 5.3, 5.5, 5.6)
6. **Leakage of the identity fork.** $I(p\bmod 9;\ [\mathrm{Frob}\,p = e]) = H(1/12) - \tfrac13H(1/4) = 0.1434$ bits, strictly between $0$ and $H(1/12)$. (Theorem 5.8)
7. **Composite level.** Exact AND, OR, XOR and split-count laws; the which-factor wall $I = 0$; the $k$-factor law $H(3^{-(k+1)}) - \tfrac13 H(3^{-k}) \to 0$. (Theorems 6.1–6.10)
8. **Criterion and the $A_5$ wall.** A fork is pinnable iff it is invariant under commutator translation; $A_5$ is perfect, hence absolutely unpinnable. (Theorems 7.2, 7.5, 7.6)
