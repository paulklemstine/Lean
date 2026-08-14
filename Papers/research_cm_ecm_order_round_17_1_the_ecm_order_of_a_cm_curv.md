# Complex Multiplication and the Residue Shadow of Elliptic Point Counts

### Exact supersingularity dichotomies for $y^2 = x^3 + x$ and $y^2 = x^3 + 1$, and the collapse of their factoring content to the abelian $p+1$ channel

**Author:** Aristotle

**Date:** 2026-08-14

---

## Abstract

Let $N = pq$ be a semiprime and let $\ell$ be a small prime. For a curve $E$ over $\mathbb{Q}$ with good reduction, one may ask how much information the residue $N \bmod m$ carries about the divisibility events $\ell \mid \#E(\mathbb{F}_p)$ and $\ell \mid \#E(\mathbb{F}_q)$. For a curve whose mod-$\ell$ Galois representation has full image the answer is: none measurable. We show that this invisibility is a *generic* phenomenon by exhibiting, for curves with complex multiplication, an exact structural mechanism that partially restores it — and by proving that what is restored is precisely the abelian channel already exploited by the $p+1$ method.

We give complete, elementary proofs of the following. For the Gaussian curve $E_{-4} : y^2 = x^3 + x$ and any odd prime $p$, the trace of Frobenius satisfies $a_p = 0$ if and only if $p \equiv 3 \pmod 4$; moreover $4 \mid \#E_{-4}(\mathbb{F}_p)$ for every odd $p$. The "only if" direction is derived as a corollary of the mod-$4$ point count rather than from complex-multiplication theory. The same argument shows that the entire quartic-twist family $y^2 = x^3 + Ax$ has exactly $p+1$ points at every inert prime, and yields the quadratic-twist relation $\#E + \#E^{u} = 2p+2$. For the Eisenstein curve $E_{-3} : y^2 = x^3 + 1$ and any prime $p \notin \{2,3\}$, $a_p = 0$ if and only if $p \equiv 2 \pmod 3$; on the inert half the entire family $y^2 = x^3 + B$ has $p+1$ points, and on the split half $3 \mid \#E_{-3}(\mathbb{F}_p)$ via a free action of $\mathbb{Z}/3$ off the fibre over $x = 0$.

We then quantify the resulting residue shadow. We prove that the symmetric channel is genuinely live: if $p, q \equiv 3 \pmod 4$ and $pq \equiv 5 \pmod{12}$ then $3 \mid \#E_{-4}(\mathbb{F}_p)$ or $3 \mid \#E_{-4}(\mathbb{F}_q)$. Empirically this corresponds to $0.0048$ and $0.0062$ bits of mutual information at $\ell = 3, 5$, roughly $4.8$ times the noise floor, against $0.0000$ for a non-CM curve on the same data. We prove that the asymmetric (which-factor) channel is nonetheless empty, exhibiting the collision $77 \equiv 209 \pmod{12}$ with identical symmetric values and opposite least-factor bits; that even the symmetric channel is only partial; that for $E_{-3}$ at $\ell = 5$ the symmetric channel is dead as well; and that on the inert half the elliptic stage-one divisibility test *is* the $p+1$ test. The verdict is a confirmed null for factoring: complex multiplication restores a residue shadow, but only the abelian one.

**Keywords:** complex multiplication, supersingular reduction, trace of Frobenius, quadratic character sums, elliptic curve factorization, $p+1$ method, mutual information, residue channels.

---

## 1. Introduction

### 1.1 The question

Fix an elliptic curve $E$ over $\mathbb{Q}$ and a small prime $\ell$. For each prime $p$ of good reduction we obtain a finite abelian group $E(\mathbb{F}_p)$ of order
$$\#E(\mathbb{F}_p) = p + 1 - a_p, \qquad |a_p| \le 2\sqrt{p},$$
and a Boolean observable $\big[\ell \mid \#E(\mathbb{F}_p)\big]$. Given a semiprime $N = pq$ whose factorization is unknown, the *residue channel* asks: how much does $N \bmod m$, for a fixed modulus $m$, reveal about these observables at the hidden factors?

The question is not idle. Every stage of the elliptic curve method of factorization (ECM) succeeds precisely when $\#E(\mathbb{F}_p)$ is smooth for the smaller factor $p$. If a cheap statistic of $N$ correlated with the smoothness — or even with a single divisibility $\ell \mid \#E(\mathbb{F}_p)$ — one could bias curve selection towards success. The analogous question for the *abelian* groups $\mathbb{F}_p^{\times}$ and the norm-one torus, which underlie the $p-1$ and $p+1$ methods, has a loud positive answer: $\ell \mid p-1$ is equivalent to $p \equiv 1 \pmod \ell$, a congruence directly constrained by $N \bmod \ell$.

For a curve with surjective mod-$\ell$ representation, the divisibility $\ell \mid \#E(\mathbb{F}_p)$ is equivalent to the Frobenius conjugacy class in $\mathrm{GL}_2(\mathbb{F}_\ell)$ having eigenvalue $1$, a condition on a $\mathrm{GL}_2$-extension linearly disjoint from the cyclotomic tower. No congruence on $p$ modulo any fixed $m$ can detect it. Empirically, on six thousand random semiprimes, the mutual information $I(N \bmod \ell \,;\, \ell \mid \#E(\mathbb{F}_p) \text{ or } \ell \mid \#E(\mathbb{F}_q))$ measures $0.0000$ bits at $\ell = 3$ and $0.0003$ at $\ell = 5$, both inside the null band, while the $p-1$ control on the same data returns $0.3167$ bits.

### 1.2 The intervention

This paper asks what happens when one *deliberately* destroys the $\mathrm{GL}_2$-genericity by choosing a curve with complex multiplication, so that the image of Galois is contained in the normalizer of a Cartan subgroup and hence is *abelian up to index two*. Two such curves are reachable with entirely elementary tools:
$$E_{-4} : y^2 = x^3 + x \quad (\mathrm{End} = \mathbb{Z}[i]), \qquad E_{-3} : y^2 = x^3 + 1 \quad (\mathrm{End} = \mathbb{Z}[\zeta_3]).$$
For each, the supersingular set — the set of primes with $a_p = 0$ — is a congruence class of density $1/2$, so the point count degenerates to the purely abelian quantity $p+1$ on half of all primes. If any elliptic curve leaks its point count through the residue of $N$, these do.

### 1.3 Results

Sections 2–4 prove the structural facts:

- **Theorem 2.6** (exact Gaussian dichotomy): for $p$ odd, $a_p(E_{-4}) = 0 \iff p \equiv 3 \pmod 4$.
- **Theorem 2.5** (universal $4$-divisibility): $4 \mid \#E_{-4}(\mathbb{F}_p)$ for every odd $p$.
- **Theorem 3.4** (family supersingularity and the twist law): for $p \equiv 3 \pmod 4$ every curve $y^2 = x^3 + Ax$ has $p+1$ points; and $\#E_{A,B} + \#E_{u^2A, u^3B} = 2p+2$ for a non-residue $u$.
- **Theorem 3.6**: on the split half $a_p \equiv 2 \pmod 4$, so the Gauss parameter $a$ in $p = a^2 + b^2$, $|a_p| = 2a$, is odd — obtained without Jacobsthal sums.
- **Theorem 4.5** (exact Eisenstein dichotomy): for $p \notin \{2,3\}$, $a_p(E_{-3}) = 0 \iff p \equiv 2 \pmod 3$, with $3 \mid \#E_{-3}(\mathbb{F}_p)$ on the split half.
- **Theorem 4.6**: the two dichotomies are independent congruence conditions.

Section 5 quantifies the shadow:

- **Theorem 5.2** (symmetric channel live): $p, q \equiv 3 \pmod 4$ and $pq \equiv 5 \pmod{12}$ imply $3 \mid \#E_{-4}(\mathbb{F}_p)$ or $3 \mid \#E_{-4}(\mathbb{F}_q)$.
- **Theorem 5.4** (which-factor null): $77$ and $209$ are congruent mod $12$, both satisfy the symmetric event, and their least-factor bits differ.
- **Theorem 5.5**: the symmetric bit is itself only partially determined by $N \bmod 12$.
- **Theorem 5.6** (Eisenstein null): for $E_{-3}$ at $\ell = 5$ each of the four attainable residues mod $15$ is realized with both truth values of the symmetric event.
- **Theorem 5.7**: on the inert half, elliptic stage one is the $p+1$ method verbatim.

Section 6 reports the numerical experiment, Section 7 the discussion and the barrier analysis, Section 8 future directions.

---

## 2. The Gaussian curve: an exact dichotomy from a sign

Throughout, $p$ denotes an odd prime, $\chi$ the quadratic character of $\mathbb{F}_p$ (with $\chi(0) = 0$), and for $A, B \in \mathbb{F}_p$ we write $f_{A,B}(x) = x^3 + Ax + B$.

**Definition 2.1.** For $A, B \in \mathbb{F}_p$ with nonzero discriminant, $\#E_{A,B}(\mathbb{F}_p)$ denotes the number of affine solutions of $y^2 = f_{A,B}(x)$ plus one. We set $\#E_{-4}(\mathbb{F}_p) = \#E_{1,0}(\mathbb{F}_p)$ and $a_p = p + 1 - \#E_{-4}(\mathbb{F}_p)$.

**Lemma 2.2 (non-residuality of $-1$).** If $p \equiv 3 \pmod 4$ then $-1$ is not a square in $\mathbb{F}_p$. Consequently, for $c \ne 0$, the product $c \cdot (-c)$ is not a square.

*Proof.* The first claim is Euler's criterion, $(-1)^{(p-1)/2} = -1$. For the second, if $c(-c) = s^2$ then $(s/c)^2 = -1$. $\square$

**Lemma 2.3 (the sign involution).** Let $p \equiv 3 \pmod 4$ and $x \ne 0$. Then $f_{1,0}(x) = x(x^2+1) \ne 0$, and exactly one of $f_{1,0}(x)$, $f_{1,0}(-x)$ is a nonzero square.

*Proof.* If $x(x^2+1) = 0$ with $x \ne 0$ then $x^2 = -1$, contradicting Lemma 2.2. Since $f_{1,0}$ is odd, $f_{1,0}(-x) = -f_{1,0}(x)$, and their product is $-f_{1,0}(x)^2$, a non-square by Lemma 2.2. Hence exactly one factor is a square. $\square$

**Theorem 2.4 (supersingularity on the inert half).** If $p \equiv 3 \pmod 4$ then $\#E_{-4}(\mathbb{F}_p) = p+1$, i.e. $a_p = 0$.

*Proof sketch.* Partition $\mathbb{F}_p^{\times}$ into the $(p-1)/2$ pairs $\{x, -x\}$. By Lemma 2.3, each pair contributes exactly $2$ affine points: two from the member where $f_{1,0}$ is a nonzero square, none from the other. Over $x = 0$ we have $f_{1,0}(0) = 0$, contributing the single point $(0,0)$. Adding the point at infinity,
$$\#E_{-4}(\mathbb{F}_p) = 2 \cdot \tfrac{p-1}{2} + 1 + 1 = p+1. \qquad \square$$

Formally, one shows $2 \cdot \#\{x : f_{1,0}(x) \text{ is a nonzero square}\} = p-1$ by exhibiting the bijection $x \mapsto -x$ between the square set and its complement in $\mathbb{F}_p^{\times}$.

**Theorem 2.5 (universal divisibility by four).** For every odd prime $p$, $4 \mid \#E_{-4}(\mathbb{F}_p)$.

*Proof sketch.* If $p \equiv 3 \pmod 4$ then $\#E_{-4}(\mathbb{F}_p) = p+1 \equiv 0 \pmod 4$ by Theorem 2.4. If $p \equiv 1 \pmod 4$ then $-1 = i^2$ for some $i \in \mathbb{F}_p^{\times}$, and $x^3 + x = x(x-i)(x+i)$ has three distinct roots $0, i, -i$. Each root gives a point of order two; together with the identity these span a subgroup isomorphic to $(\mathbb{Z}/2)^2$, so $4 \mid \#E_{-4}(\mathbb{F}_p)$ by Lagrange. (Equivalently, a direct count: the number of $x$ with $f_{1,0}(x)$ a nonzero square has a fixed parity forced by the three-root configuration.) $\square$

**Theorem 2.6 (the exact dichotomy).** For every odd prime $p$,
$$a_p = 0 \iff p \equiv 3 \pmod 4.$$

*Proof.* ($\Leftarrow$) is Theorem 2.4. ($\Rightarrow$): suppose $p \equiv 1 \pmod 4$. Then $p + 1 \equiv 2 \pmod 4$, while $4 \mid \#E_{-4}(\mathbb{F}_p)$ by Theorem 2.5, so $\#E_{-4}(\mathbb{F}_p) \ne p+1$ and $a_p \ne 0$. $\square$

**Remark 2.7.** This is, to our knowledge, the cheapest route to the classical statement that $y^2 = x^3+x$ is supersingular exactly at $p \equiv 3 \pmod 4$. The usual argument invokes the theory of complex multiplication, Deuring's criterion, or the evaluation of a Jacobsthal sum. Here *ordinarity of the split half is a corollary of a mod-$4$ point count*: the two halves cooperate, each supplying what the other lacks.

---

## 3. Character sums: the whole family and the twist involution

**Definition 3.1.** The *quadratic character sum* of $f_{A,B}$ is
$$S(A,B) \;=\; \sum_{x \in \mathbb{F}_p} \chi\big(x^3 + Ax + B\big) \;\in\; \mathbb{Z}.$$

**Proposition 3.2 (character-sum point count).** For $p$ odd,
$$\#E_{A,B}(\mathbb{F}_p) = p + 1 + S(A,B).$$

*Proof sketch.* For each $x$, the number of $y$ with $y^2 = f_{A,B}(x)$ equals $1 + \chi(f_{A,B}(x))$ — this is $2$ for a nonzero square, $0$ for a non-square, $1$ for zero. Summing over $x$ gives $p + S(A,B)$ affine points; add the point at infinity. $\square$

In particular $S(A,B) = -a_p$ for the corresponding curve.

**Proposition 3.3 (odd cubics on the inert half).** If $p \equiv 3 \pmod 4$ then $S(A, 0) = 0$ for every $A \in \mathbb{F}_p$.

*Proof.* Since $f_{A,0}$ is odd and $\chi(-1) = -1$ (Lemma 2.2), the substitution $x \mapsto -x$ gives $S(A,0) = -S(A,0)$. $\square$

**Theorem 3.4 (family supersingularity; the twist law).** Let $p$ be odd.

1. If $p \equiv 3 \pmod 4$, then for every $A \in \mathbb{F}_p$ the curve $y^2 = x^3 + Ax$ has exactly $p+1$ points. Supersingularity is thus a property of the whole quartic-twist family, not of the model $A = 1$.
2. For $u$ a quadratic non-residue and any $A, B$,
$$\#E_{A,B}(\mathbb{F}_p) + \#E_{u^2 A,\, u^3 B}(\mathbb{F}_p) = 2p + 2.$$

*Proof sketch.* (1) is Propositions 3.2–3.3. For (2), the substitution $x \mapsto ux$ gives $f_{u^2A, u^3B}(ux) = u^3 f_{A,B}(x)$, whence $S(u^2A, u^3B) = \chi(u^3)\,S(A,B) = \chi(u)\,S(A,B) = -S(A,B)$, using $\chi(u)^2 = 1$. Now add the two instances of Proposition 3.2. $\square$

**Corollary 3.5.** For the Gaussian curve and a non-residue $u$, $\#E_{-4}(\mathbb{F}_p) + \#E_{u^2,0}(\mathbb{F}_p) = 2p+2$. At $p = 5$: $4 + 8 = 12$. Combined with Theorem 2.5, at a split prime both summands are divisible by $4$ while their sum is $\equiv 4 \pmod 8$, so exactly one of the two quartic-twist orbits has order divisible by $8$.

**Theorem 3.6 (the Gauss parameter is odd).** If $p \equiv 1 \pmod 4$ then $a_p \equiv 2 \pmod 4$. Consequently, writing $p = a^2 + b^2$ with $|a_p| = 2a$ (Gauss, 1801), the parameter $a$ is odd.

*Proof.* $\#E_{-4}(\mathbb{F}_p) = 4k$ by Theorem 2.5 and $p \equiv 1 \pmod 4$, so $a_p = p+1-4k \equiv 2 \pmod 4$. $\square$

**Remark 3.7.** Theorem 3.6 recovers the normalization half of the Gauss law with no Jacobsthal sums; Theorem 3.4(2) supplies the sign-flip half, since the two quartic twists realize the two signs. What is missing to obtain the full law $a_p^2 = 4a^2$ is only the norm identity $a_p^2 + 4b^2 = 4p$; see Section 8, Conjecture A.

---

## 4. The Eisenstein mirror: $j = 0$ and an order-three symmetry

We now perform the same analysis at the other class-number-one discriminant reachable elementarily, $D = -3$, i.e. the family $y^2 = x^3 + B$ with $j$-invariant $0$. Write $\#E_{-3}(\mathbb{F}_p) = \#E_{0,1}(\mathbb{F}_p)$ and $a'_p = p+1-\#E_{-3}(\mathbb{F}_p)$.

### 4.1 Inert primes: cubing is a bijection

**Lemma 4.1.** If $p \equiv 2 \pmod 3$ then $x \mapsto x^3$ is a bijection of $\mathbb{F}_p$, with explicit inverse $x \mapsto x^{k}$ where $k = (2p-1)/3$.

*Proof.* Since $p \equiv 2 \pmod 3$, $3k = 2(p-1)+1$. For $x = 0$ the claim is trivial; for $x \ne 0$, $(x^3)^k = x^{2(p-1)+1} = x$ by Fermat. Injectivity follows, and a self-map of a finite set that is injective is bijective. $\square$

**Theorem 4.2 (supersingularity of the whole $j=0$ family).** If $p \ne 2$ and $p \equiv 2 \pmod 3$, then $S(0,B) = 0$ and hence $\#E_{0,B}(\mathbb{F}_p) = p+1$ for *every* $B \in \mathbb{F}_p$.

*Proof.* By Lemma 4.1 the substitution $t = x^3$ is a reindexing, so
$$S(0,B) = \sum_{x} \chi(x^3 + B) = \sum_{t} \chi(t + B) = \sum_{s} \chi(s) = 0,$$
the last equality because a nontrivial character sums to zero over the whole field. Apply Proposition 3.2. $\square$

### 4.2 Split primes: a free $\mathbb{Z}/3$-action

**Lemma 4.3 (orbit counting for an order-three symmetry).** Let $S$ be a finite set and $\sigma : S \to S$ with $\sigma^3 = \mathrm{id}$ and $\sigma(s) \ne s$ for all $s \in S$. Then $3 \mid \#S$.

*Proof sketch.* Strong induction on $\#S$. If $S = \emptyset$ we are done. Otherwise pick $s \in S$. The elements $s, \sigma s, \sigma^2 s$ are pairwise distinct: $\sigma s \ne s$ and $\sigma^2 s \ne \sigma s$ by freeness, and $\sigma^2 s = s$ would give $\sigma s = \sigma^3 s = s$. So $O = \{s, \sigma s, \sigma^2 s\}$ has three elements, is $\sigma$-stable, and $S \setminus O$ is again $\sigma$-stable (because $\sigma$ is injective) with a free action, so $3 \mid \#(S\setminus O) = \#S - 3$. $\square$

**Theorem 4.4 (three-divisibility on the split half).** If $p \ne 2$ and $p \equiv 1 \pmod 3$, then $3 \mid \#E_{-3}(\mathbb{F}_p)$.

*Proof sketch.* Since $3 \mid p-1$, the group $\mathbb{F}_p^{\times}$ contains an element $\zeta$ of order $3$. Define $\sigma(x,y) = (\zeta x, y)$ on the affine points of $y^2 = x^3+1$; it preserves the curve since $(\zeta x)^3 = x^3$, and $\sigma^3 = \mathrm{id}$. Split the affine points into the fibre over $x = 0$ and the rest. The fibre over $x = 0$ consists of the two points $(0, \pm 1)$ (distinct since $p \ne 2$). On the complement $\sigma$ is fixed-point-free: $\zeta x = x$ with $x \ne 0$ forces $\zeta = 1$. By Lemma 4.3 the complement has cardinality divisible by $3$, so the total point count is $\equiv 2 + 1 = 3 \equiv 0 \pmod 3$, the extra $1$ being the point at infinity. $\square$

**Theorem 4.5 (the exact $j = 0$ dichotomy).** For every prime $p \notin \{2,3\}$,
$$a'_p = 0 \iff p \equiv 2 \pmod 3.$$

*Proof.* ($\Leftarrow$) is Theorem 4.2. ($\Rightarrow$): if $p \equiv 1 \pmod 3$ then $p+1 \equiv 2 \pmod 3$ while $3 \mid \#E_{-3}(\mathbb{F}_p)$ by Theorem 4.4, so $\#E_{-3}(\mathbb{F}_p) \ne p+1$. $\square$

The structural parallel with Section 2 is exact, with $2 \leftrightarrow 3$: in both cases a symmetry of the curve forces $\ell \mid \#E$ on the split half, and $p+1 \not\equiv 0 \pmod \ell$ there rules out supersingularity. At $D = -4$ the symmetry is rational $2$-torsion (an involution on points); at $D = -3$ it is the order-three automorphism fixing the inflection points. The exceptional primes are $p = 2$ and $p = 3$ respectively.

**Theorem 4.6 (independence of the two dichotomies).** The supersingular loci of $E_{-4}$ and $E_{-3}$ are cut out by independent congruences. Concretely, $a_5 \ne 0$ while $a'_5 = 0$, and $a_7 = 0$ while $a'_7 \ne 0$. Hence at $p \equiv 7 \pmod{12}$ the Gaussian curve is supersingular and the Eisenstein curve ordinary, and at $p \equiv 5 \pmod{12}$ the reverse.

*Proof.* Immediate from Theorems 2.6 and 4.5 and the Chinese Remainder Theorem. $\square$

**Corollary 4.7.** There is no single "complex-multiplication shadow" on the residue of $p$: which congruence class is visible depends on the discriminant of the curve. Any adversary must commit to a curve, and thereby to a modulus.

---

## 5. The residue shadow and its factoring content

We now ask what the above structure gives an observer who sees only $N = pq$ and knows nothing about $p$ and $q$.

**Definition 5.1.** Fix a prime $\ell$ and a modulus $m$. For $N = pq$ with $p < q$ set
$$\mathrm{Sym}_\ell(N) = \big[\ell \mid \#E(\mathbb{F}_p)\big] \vee \big[\ell \mid \#E(\mathbb{F}_q)\big], \qquad \mathrm{Asym}_\ell(N) = \big[\ell \mid \#E(\mathbb{F}_p)\big].$$
The *symmetric channel* is $I(N \bmod m \,;\, \mathrm{Sym}_\ell)$ and the *asymmetric (which-factor) channel* is $I(N \bmod m \,;\, \mathrm{Asym}_\ell)$, both in bits.

Only the asymmetric channel has factoring value: an algorithm must know which factor to chase.

### 5.1 The symmetric channel is live

On the inert half, $\#E_{-4}(\mathbb{F}_p) = p+1$ exactly, so for $2 \le \ell$ we have
$$\ell \mid \#E_{-4}(\mathbb{F}_p) \iff p \equiv -1 \!\!\pmod \ell,$$
a *congruence condition on $p$*. Consequently, two inert primes agreeing modulo $4\ell$ have the same divisibility bit: the entire elliptic information exposed on the inert half is contained in $p \bmod 4\ell$.

**Theorem 5.2 (the symmetric leak).** Let $p, q$ be primes with $p \equiv q \equiv 3 \pmod 4$ and $pq \equiv 5 \pmod{12}$. Then
$$3 \mid \#E_{-4}(\mathbb{F}_p) \quad\text{or}\quad 3 \mid \#E_{-4}(\mathbb{F}_q).$$

*Proof.* Each of $p, q$ lies in $\{3, 7, 11\} \bmod 12$. Multiplying out the nine cases modulo $12$ gives $pq \equiv 5$ only when at least one factor is $\equiv 11 \pmod{12}$ (indeed $3\cdot 3 = 9$, $3 \cdot 7 = 9$, $7 \cdot 7 = 1$, while $3 \cdot 11 = 9$, $7 \cdot 11 = 5$, $11 \cdot 11 = 1$; the residue $5$ arises only from $\{7, 11\}$). Say $p \equiv 11 \pmod{12}$. Then $p \equiv 3 \pmod 4$, so $\#E_{-4}(\mathbb{F}_p) = p+1$ by Theorem 2.4, and $p \equiv 2 \pmod 3$, so $3 \mid p+1$. $\square$

This is a *proved* positive residue signal on an elliptic point count. It is the mechanism behind the measured excess reported in Section 6.

**Remark 5.3 (why the signal is weak).** Decompose the unconditional probability at $\ell = 3$:
$$\Pr\big[3 \mid \#E_{-4}(\mathbb{F}_p)\big] \;=\; \underbrace{\Pr[\text{inert}] \cdot \Pr[3 \mid p+1 \mid \text{inert}]}_{\approx\, 0.515 \times 0.515} \;+\; \underbrace{\Pr[\text{split}] \cdot \Pr[3 \mid \#E \mid \text{split}]}_{\approx\, 0.484 \times 0.117}.$$
The first term is a congruence and is in principle visible; the second is governed by the trace $a_p = \pm 2a$ with $p = a^2+b^2$, i.e. by the splitting of $p$ in a ray class field, and is invisible from any fixed residue of $p$. Moreover the visible term is itself a *conjunction* — "the factor is $\equiv 3 \pmod 4$ **and** $\equiv -1 \pmod 3$", i.e. $\equiv 11 \pmod{12}$ — and the mod-$4$ conjunct is not recoverable from $N \bmod 3$. This dilutes the signal by roughly a factor of forty relative to the $p-1$ channel, whose visible event is the single congruence $p \equiv 1 \pmod \ell$.

### 5.2 The asymmetric channel is empty

**Theorem 5.4 (which-factor null).** Consider $N_1 = 77 = 7 \cdot 11$ and $N_2 = 209 = 11 \cdot 19$. Then:
$$N_1 \equiv N_2 \equiv 5 \pmod{12};$$
$$\#E_{-4}(\mathbb{F}_7) = 8, \quad \#E_{-4}(\mathbb{F}_{11}) = 12, \quad \#E_{-4}(\mathbb{F}_{19}) = 20;$$
so $\mathrm{Sym}_3(N_1) = \mathrm{Sym}_3(N_2) = \text{true}$, while $\mathrm{Asym}_3(N_1) = \text{false}$ and $\mathrm{Asym}_3(N_2) = \text{true}$. Hence no function of $N \bmod 12$ agrees with the which-factor bit on all semiprimes with two inert factors.

*Proof.* All three primes are $\equiv 3 \pmod 4$, so their point counts are $p+1$ by Theorem 2.4, giving $8, 12, 20$. Then $3 \nmid 8$, $3 \mid 12$, $3 \nmid 20$, and $77 = 6\cdot 12 + 5$, $209 = 17\cdot 12 + 5$. $\square$

**Theorem 5.5 (the symmetric bit is only partial).** $133 = 7 \cdot 19$ and $253 = 11 \cdot 23$ are both $\equiv 1 \pmod{12}$, yet $\mathrm{Sym}_3(133) = \text{false}$ (counts $8$ and $20$) while $\mathrm{Sym}_3(253) = \text{true}$ (counts $12$ and $24$).

Thus even the live symmetric channel is a partial constraint, not a decision procedure: the residue $5 \bmod 12$ forces the event, but the residue $1 \bmod 12$ leaves it undetermined. This is precisely the profile of a low-bit-rate channel.

**Theorem 5.6 (the Eisenstein symmetric channel is dead at $\ell = 5$).** Products of two $E_{-3}$-inert primes coprime to $5$ occupy the four residues $\{1, 4, 7, 13\} \bmod 15$, and each is realized both with and without the symmetric event. Explicitly, using $\#E_{-3}(\mathbb{F}_p) = p+1$ on the inert half:

| residue mod $15$ | event false | event true |
|---|---|---|
| $4$ | $799 = 17\cdot 47$ ($18, 48$) | $319 = 11\cdot 29$ ($12, 30$) |
| $1$ | $391 = 17\cdot 23$ ($18, 24$) | $1711 = 29\cdot 59$ ($30, 60$) |
| $7$ | $187 = 17\cdot 11$ ($18, 12$) | $667 = 23\cdot 29$ ($24, 30$) |
| $13$ | $253 = 23\cdot 11$ ($24, 12$) | $493 = 17\cdot 29$ ($18, 30$) |

Consequently $I(N \bmod 15 \,;\, \mathrm{Sym}_5) $ has no forced-value support at all. The structural reason: the inert residues $\{2,8,11,14\} \bmod 15$ form a coset closed under multiplication by $-1$, so the product set is a full group and no residue isolates the condition "$\equiv -1 \pmod 5$". Contrast Theorem 5.2, where the inert residues mod $12$ form a smaller set $\{3,7,11\}$ and the product residue $5$ does isolate a factor.

The which-factor bit fails for $E_{-3}$ as well: $319 = 11 \cdot 29$ and $1189 = 29 \cdot 41$ agree mod $15$, both satisfy the symmetric event ($\#E_{-3}(\mathbb{F}_{29}) = 30$), and the least-factor bits are false and true respectively ($\#E_{-3}(\mathbb{F}_{11}) = 12$, $\#E_{-3}(\mathbb{F}_{29}) = 30$).

### 5.3 On the inert half the method is not new

**Theorem 5.7 (stage one collapses to $p+1$).** Let $p \equiv 3 \pmod 4$ and let $M$ be any integer (in practice the stage-one multiplier $\mathrm{lcm}$ of prime powers up to a bound). Then
$$\#E_{-4}(\mathbb{F}_p) \mid M \iff (p+1) \mid M,$$
and for any smoothness bound $B$, $\#E_{-4}(\mathbb{F}_p)$ is $B$-smooth if and only if $p+1$ is $B$-smooth.

*Proof.* Theorem 2.4. $\square$

So on exactly the half of the primes where the special curve exhibits a visible shadow, running the elliptic method on it is running Williams's $p+1$ method — an abelian technique whose residue channel is already understood and already exhausted.

**Theorem 5.8 (the split half is not a refinement either).** At $p = 5$: $\#E_{-4}(\mathbb{F}_5) = 4$ while $p+1 = 6$. Thus $3 \mid p+1$ but $3 \nmid \#E_{-4}(\mathbb{F}_5)$, and $\#E_{-4}(\mathbb{F}_5) \ne p+1$. Hence the CM curve neither refines nor is refined by the $p+1$ method; it re-partitions the primes.

This is the crux of the four-way experimental contrast in Section 6: the CM curve captures a target set that the $p+1$ method misses (split primes with smooth CM order) and *misses* target primes the $p+1$ method captures (split primes with smooth $p+1$ but rough CM order).

---

## 6. Numerical experiment

**Setup.** Six thousand semiprimes $N = pq$ with $p, q$ random primes in a fixed bit range. For each we recorded the residue $N \bmod m$ for $m \in \{\ell, 4\ell\}$, $\ell \in \{3,5,7\}$, and the events $\mathrm{Sym}_\ell$, $\mathrm{Asym}_\ell$ for the Gaussian CM curve, a non-CM control curve, and the classical $p-1$ channel. Mutual information was estimated by plug-in on the empirical joint distribution; the null band was calibrated by label permutation preserving marginals.

**Structural verifications.**

| statement | result |
|---|---|
| $a_p = 0$ on inert primes $p \equiv 3 \pmod 4$ | $2027/2027$ |
| $\|a_p\| = 2a$, $p = a^2+b^2$, $a$ odd, on split primes | $1973/1973$ |
| $4 \mid \#E_{-4}(\mathbb{F}_p)$ | $1000/1000$ (generic curve: $458/1000$) |
| $\Pr[a_p = 0]$ for $E_{-4}$ | $0.507$ (semicircle prediction: $0.004$) |
| $\Pr[\lvert a_p\rvert/2\sqrt{p} < 0.5]$ for $E_{-4}$ | $0.683$ (semicircle: $0.607$) |

The trace law of the CM curve is *atomic*: half its mass sits on the single value $0$, whereas the generic (Sato–Tate) law is absolutely continuous with the semicircular density.

**Information measurements (bits).**

| channel | $\ell = 3$ | $\ell = 5$ | $\ell = 7$ |
|---|---|---|---|
| symmetric, CM curve | $0.0048$ | $0.0062$ | in null |
| symmetric, non-CM curve | $0.0000$ | $0.0003$ | in null |
| asymmetric, CM curve | $0.0000$ | $0.0005$ | $0.0009$ (all in null) |
| $p-1$ control | $0.3167$ | — | — |

The symmetric CM entries are each about $4.8\times$ the maximum of the permuted null ($p < 0.002$); the asymmetric entries are inside it. The $p-1$ control matches its theoretical value $\approx 0.313$, confirming the estimator.

Enriching the residue from $N \bmod \ell$ to $N \bmod 4\ell$ amplifies the symmetric signal by roughly an order of magnitude (to $\approx 0.04$ bits at $\ell = 3$ in our replication), exactly as Remark 5.3 predicts: the extra modulus exposes the mod-$4$ conjunct that made the event a conjunction. The asymmetric channel does **not** amplify — it stays at the null under every modulus tried, consistent with Theorem 5.4.

**Smoothness.** Full stage-one smoothness $M \mid \#E_{-4}(\mathbb{F}_p)$ occurs with probability $0.619$ at the parameters used, and is driven entirely by the *size* of the group, not by residues: the mutual information with $N \bmod m$ is at the null for every $m$ tested.

**The four-way stage-one contrast.** Partitioning target primes by (inert/split) $\times$ ($p+1$-smooth / CM-smooth):

| stratum | CM-curve stage one | plain $p+1$ method |
|---|---|---|
| inert, $p+1$ smooth | $40/40$ | $40/40$ (identical test, Theorem 5.7) |
| inert, $p+1$ rough | $0/40$ | $0/40$ |
| split, CM order smooth | $40/40$ | $40/40$ on its own target set, which this misses |
| split, $p+1$ smooth but CM order rough | $4/40$ | $0/4$ of those fire spuriously |

The reading: on the inert half the two methods coincide; on the split half they target *disjoint* sets of primes, and the CM curve misses the primes on which the genuine $p+1$ method succeeds. Re-partitioning a known target set is not progress.

---

## 7. Discussion

### 7.1 What the CM intervention actually buys

The elliptic point count of a generic curve is invisible from residues because the mod-$\ell$ image of Galois is all of $\mathrm{GL}_2(\mathbb{F}_\ell)$, a group with no abelian quotient that the cyclotomic character can see. Complex multiplication shrinks that image into (the normalizer of) a Cartan subgroup. One might expect the whole point count to become congruence-visible. It does not, and the reason is structurally sharp: the Cartan is a *torus*, its two eigenvalue characters are ray class characters of the imaginary quadratic field $K$, and only the *product* of those characters — the cyclotomic character, i.e. $p$ itself — is visible from $p \bmod m$. On the inert half the two characters are swapped by the nontrivial element of the normalizer, forcing the trace to zero and leaving the order equal to $p+1$: fully visible, but fully abelian. On the split half the individual characters survive and the trace is $\pm 2a$ with $p = a^2 + b^2$; this depends on the *ideal* above $p$, not on $p$'s residue, and is therefore invisible.

Thus the CM curve's shadow decomposes exactly as in Remark 5.3 into a visible abelian term and an invisible ray-class term. Restoring the CM symmetry restores only the term that was never elliptic.

### 7.2 The barriers

Four obstructions, each independent, close the channel.

1. **Commutativity of multiplication (the which-factor barrier).** Any statistic of $N \bmod M$ is symmetric in $p$ and $q$; the least-factor bit is not. Theorem 5.4 realizes the obstruction concretely.
2. **Abelian redundancy.** Where the signal is strong ($\#E = p+1$), the algorithm reduces to a known method (Theorem 5.7); where the algorithm is new (the split half), the signal is absent.
3. **Size-driven smoothness.** Full stage-one success is governed by the magnitude of the group order, which is $p + O(\sqrt p)$ regardless of residue class; the residue only shifts small-prime divisibilities, contributing $O(1)$ bits at most.
4. **Conjunction dilution.** The visible event is a conjunction of an $\ell$-condition and a $4$-condition (or a $3$-condition), and the residue modulus must contain both to see it — costing information roughly multiplicatively.

### 7.3 What survives as pure mathematics

Independently of the negative verdict, Sections 2–4 give an unusually economical treatment of two classical facts:

- The Gaussian dichotomy is proved with a sign involution plus a two-torsion count. Neither Deuring's criterion, nor Jacobsthal sums, nor quadratic reciprocity appears; the split half's ordinarity is a *corollary* of the inert half's divisibility.
- The Eisenstein dichotomy is proved with a cube-map bijection plus a free $\mathbb{Z}/3$-action, with an orbit-counting lemma established from first principles.
- Both extend to whole families ($y^2 = x^3 + Ax$ for all $A$; $y^2 = x^3 + B$ for all $B$), which shows the mechanism is the symmetry, not the model.
- The quadratic-twist relation $\#E + \#E^u = 2p+2$ and the mod-$4$ trace congruence recover the normalization and sign structure of the Gauss law without Jacobsthal sums.

### 7.4 Scope and limitations

The two families treated are the only class-number-one CM discriminants for which the mechanism reduces to a single symmetry of the defining equation; other discriminants require genuine class field theory. The information measurements are plug-in estimates on finite samples and are reported with a permutation null; they are consistent with the proved statements but are not themselves theorems. The four-way stage-one contrast uses stratified sampling of $40$ primes per cell and is illustrative rather than an asymptotic claim. Finally, the negative results concern *residue* channels; they say nothing about channels built on other cheap statistics of $N$.

---

## 8. Future directions

**Conjecture A (the Gauss law from the twist involution alone).** For $p \equiv 1 \pmod 4$ write $p = a^2 + b^2$ with $a$ odd. Then $\#E_{-4}(\mathbb{F}_p) \in \{p+1-2a,\, p+1+2a\}$, and the two quartic twists $y^2 = x^3+x$, $y^2 = x^3 + u^2 x$ ($u$ a non-residue) realize the two signs; equivalently $a_p^2 = 4a^2$.

*Why it is within reach.* Theorem 3.6 already gives "$a$ is odd" and Theorem 3.4(2) gives the sign flip, so the only missing ingredient is the norm identity $a_p^2 + 4b^2 = 4p$ — a statement about the Gaussian prime $\pi = a+bi$. It can be attacked through the Thue-descent representation $p = a^2+b^2$ together with a count of points over $\mathbb{F}_{p^2}$ via $a_{p^2} = a_p^2 - 2p$. No external input is required.

**Conjecture B (the $8$-divisibility law and quartic residues).** For $p \equiv 1 \pmod 4$, $8 \mid \#E_{-4}(\mathbb{F}_p)$ if and only if $2$ is a quartic residue mod $p$ — equivalently (Gauss) $p = a^2 + 64c^2$ for integers $a, c$. On the inert half the analogous statement is the elementary $8 \mid \#E_{-4}(\mathbb{F}_p) \iff p \equiv 7 \pmod 8$.

*Why it is within reach.* Theorem 2.5 came from the rational $2$-torsion $\{O, (0,0), (i,0), (-i,0)\}$, so the next power of $2$ must be governed by which of those points is divisible by $2$ in the group — a halving condition reducing to the quartic character of $2$, precisely the object of Gauss's biquadratic reciprocity. The machinery that converts "is this $2$-torsion point halvable" into a squareness condition on an explicit element is exactly one halving step beyond what is proved here.

**Conjecture C (a congruence-closure barrier theorem).** Let $f$ be any function of the residue $N \bmod M$ for a fixed modulus $M$, and let $p < q$ be inert primes with $N = pq$. Then $f(N \bmod M)$ cannot agree with the least-factor bit $[\ell \mid \#E(\mathbb{F}_p)]$ on all such semiprimes: for every $M$ there is a collision $pq \equiv p'q' \pmod M$ with opposite bits.

*Why it is within reach.* Theorem 5.4 is the case $M = 12$, $\ell = 3$ of a general symmetry: multiplication of residues is commutative, so any $M$-residue statistic is invariant under swapping the two factors, while the least-factor bit is not. A general proof requires only producing, for each $M$, two inert primes in each of two suitable classes — a statement that should follow from Dirichlet's theorem on primes in arithmetic progressions.

Beyond these, three further directions suggest themselves. First, extend the exact-dichotomy machinery to CM discriminants of class number one beyond $-3, -4$, where the visible congruence becomes a condition modulo $|D|$ and the invisible ray-class term grows; one expects the symmetric channel to shrink proportionally. Second, quantify the "atomicity" of the CM trace law as a precise statement about the point mass at $a_p = 0$ interacting with an equidistribution theorem on the split half, and derive the exact asymptotic mutual information of the symmetric channel rather than an empirical estimate. Third, test whether the conjunction-dilution phenomenon (barrier 4) is tight: is the symmetric channel capacity at modulus $4\ell$ exactly the $p+1$ channel capacity at modulus $\ell$ scaled by the density of the inert half?

---

## 9. Conclusion

Complex multiplication makes the point count of an elliptic curve maximally predictable: on half of all primes the curves $y^2 = x^3 + x$ and $y^2 = x^3 + 1$ have exactly $p+1$ points, and this is an exact if-and-only-if, provable from a sign involution and an order-three automorphism respectively. This predictability does produce the first measurable residue signal on an elliptic point count — a symmetric channel of a few thousandths of a bit, proved live by an explicit congruence implication. But the signal is forty times weaker than the classical $p-1$ channel; it is symmetric only, with the which-factor bit provably destroyed by explicit collisions; and where it is strongest the algorithm it would inform is literally the $p+1$ method of 1982. The invisibility of the elliptic point count is therefore robust: it survives the most aggressive structural attack available, because what complex multiplication returns to view is exactly the abelian part that was already in plain sight.
