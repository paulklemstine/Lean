# Tie Geometry of Arithmetic Statistics: Exact Resolution Ceilings for the 2-adic Dial and its Quadratic-Residue Baselines

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

We develop an exact, parameter-free calculus for the maximal rank correlation attainable
by a discrete statistic, and apply it to adjudicate an empirical comparison in a
cryptographic measurement pipeline. The central object is the *tie profile* of a
statistic — the multiset of level-set cardinalities — and the central functional is its
**cube sum** $\sum_j m_j^3$. We prove that the Kendall tie correction to Spearman's
$\rho$ is exactly $\frac{1}{12}\bigl(\sum_j m_j^3 - n\bigr)$, whence the attainable
squared correlation ceiling is $1 - (\sum_j m_j^3 - n)/(n^3-n)$, a strictly decreasing
function of the cube sum at fixed sample size $n$. Coarsening a statistic increases the
cube sum and therefore lowers the ceiling.

Two exact ceilings follow. The trailing-zero (2-adic valuation) statistic at bit-length
$b$, with $N=2^b$, has ceiling $\frac{6}{7}\bigl(1 + \frac{1}{N(N+1)}\bigr)$. The bare
quadratic-residue indicator modulo an odd prime has ceiling **exactly** $3/4$, for every
odd prime — a *prime-independence law* obtained from the vanishing of the quadratic
character sum, which forces the residue classes to split as $(m, m+1)$ modulo $p = 2m+1$.

The comparison this enables is sharp. A recorded measurement at bit-length $48$ on
uniform draws reports Spearman correlations $0.777 / 0.755 / 0.801$ across three
independent seeds, all inside a validation band $[0.55,0.85]$, exceeding the bare
quadratic-residue baseline by $+0.09$ to $+0.13$ on every seed. We prove a **gap law**:
the entire tie-geometry advantage of the 2-adic dial over the bare quadratic-residue
count is $\sqrt{6/7} - \sqrt{3/4} < 0.06$ in correlation units, at every odd prime and
every bit-length. Consequently the recorded advantage cannot be a resolution artefact,
and forces the baseline reading at least $0.03$ below its own ceiling.

We further establish a **multiplicative tower law** for joint Legendre vectors over
several primes (the ceiling factorises across CRT components with no interaction term),
a **counting collapse** theorem (summing a Legendre vector into a count can only lower
the ceiling, for any list of primes), and the resulting **crossover hierarchy**: at
bit-length $48$, one symbol ($3/4$) and two counted symbols ($117/140$) lie below the
dyadic ceiling $6/7$, while three counted symbols ($2433/2756$) and two *vector* symbols
($51/56$) lie above it. A replicated-symbol tower at the prime $3$ gives the closed form
$1 - (9^r-3^r)/(27^r-3^r) \ge 1 - 2\cdot 3^{-r}$, showing the quadratic-residue baseline
is capped only in its bare, one-symbol form. Finally we record a **band-saturation
asymmetry**: the validation band $[0.55,0.85]$ leaves the quadratic-residue baseline
under $0.017$ of headroom but the dial over $0.075$, so a band calibrated on one
statistic is not transportable to the other.

**Keywords:** Spearman rank correlation, tie correction, 2-adic valuation, Legendre
symbol, quadratic residues, quadratic character sums, Chinese Remainder Theorem,
statistical resolution ceilings.

---

## 1. Introduction

### 1.1 The measurement

Consider a cryptographic sampling pipeline in which each drawn integer $x$ is assigned a
downstream scalar outcome, a *rate*. A candidate predictor — henceforth the **dial** —
is the trailing-zero count
$$T(x) \;=\; v_2(x) \;=\; \max\{\,k : 2^k \mid x\,\},$$
the 2-adic valuation, computable in a single machine instruction on standard hardware.

The empirical record under study concerns uniform draws at bit-length $48$. Across three
independent seeds the Spearman rank correlation between $T$ and the rate reads
$$\rho_1 = 0.777, \qquad \rho_2 = 0.755, \qquad \rho_3 = 0.801,$$
all inside the pre-registered validation band $[0.55, 0.85]$, with a seed spread of
$0.046 < 0.05$. On the same draws the dial exceeds a **bare quadratic-residue count**
baseline by between $+0.09$ and $+0.13$ on every seed.

### 1.2 The confound

The comparison between the two statistics is not a comparison of like with like. The
dial is many-valued with geometrically decaying level sets; the quadratic-residue
indicator is two-valued with two nearly equal level sets. Spearman's $\rho$ computed
against a statistic with heavy ties is mechanically attenuated: ties compress the rank
vector, reducing its variance and hence the attainable correlation with *any* target.

The question this paper answers is therefore: **how much of the recorded $0.09$–$0.13$
advantage is attributable to tie granularity alone, and how much is genuine coupling?**

The answer is exact, requires no simulation, and needs no distributional assumption
about the rate. Both statistics have closed-form, exactly computable resolution
ceilings; the difference of these ceilings is a hard upper bound on the geometric
component of the advantage; and that difference turns out to be below $0.06$, strictly
less than the recorded advantage.

### 1.3 Contributions

1. **A cube-sum calculus** (§3). The Kendall tie correction of a profile equals
   $\frac{1}{12}(\sum_j m_j^3 - n)$; the ceiling is $1 - (\sum_j m_j^3 - n)/(n^3-n)$;
   and at fixed $n$ the ceiling is strictly antitone in the cube sum.
2. **An arithmetic bridge** (§4). A character-sum proof that modulo $p = 2m+1$ there are
   exactly $m+1$ squares and $m$ non-squares, hence tie profile $(m, m+1)$.
3. **The prime-independence law** (§5). The bare quadratic-residue ceiling is exactly
   $3/4$ for every odd prime.
4. **The multiplicative tower law** (§6) for joint Legendre vectors, and the
   **counting collapse** (§7) for their sums.
5. **The crossover hierarchy** (§8) at bit-length $48$, and the **replicated-symbol
   tower** with its closed form and geometric lower bound.
6. **The gap law** and its corollary that the recorded advantage forces slack (§9),
   plus the **band-saturation asymmetry** and **envelope flatness** results (§10).

---

## 2. Setting and definitions

### 2.1 Tie profiles

**Definition 2.1 (Tie profile).** Let $S$ be a statistic defined on a finite population
$\Omega$ with $|\Omega| = n$. The *tie profile* of $S$ is the list
$L = (m_1, \dots, m_k)$ of cardinalities of the level sets $S^{-1}(v)$, $v \in S(\Omega)$.
Necessarily $\sum_j m_j = n$. We write $\Sigma L := \sum_j m_j$ for the sample size
recovered from the profile.

Profiles are unordered as data, but it is convenient to manipulate them as lists; every
functional below is symmetric in the entries.

**Definition 2.2 (Cube sum).** For a profile $L = (m_1,\dots,m_k)$ set
$$\operatorname{cube}(L) \;:=\; \sum_{j=1}^{k} m_j^3 .$$

The cube sum is additive over concatenation, $\operatorname{cube}(A \frown B) =
\operatorname{cube}(A) + \operatorname{cube}(B)$, and scales as
$\operatorname{cube}(aL) = a^3 \operatorname{cube}(L)$ under entrywise multiplication.

### 2.2 The tie correction and the ceiling

**Definition 2.3 (Kendall tie correction).** For a profile $L$ set
$$\mathcal{T}(L) \;:=\; \sum_{j} \frac{m_j^3 - m_j}{12}.$$

This is the classical correction term appearing in the tie-adjusted Spearman statistic.
Its role is that when a statistic with profile $L$ is rank-transformed using midranks,
the variance of the resulting rank vector is reduced from its untied value
$\frac{n^3-n}{12}$ to $\frac{n^3-n}{12} - \mathcal{T}(L)$.

**Definition 2.4 (Resolution ceiling).** For a profile $L$ with $n = \Sigma L \ge 2$
define
$$\operatorname{ceil}(L) \;:=\; 1 - \frac{12\,\mathcal{T}(L)}{n^3 - n}, \qquad
\rho_{\max}(L) := \sqrt{\operatorname{ceil}(L)} .$$

**Interpretation.** By Cauchy–Schwarz applied to the midrank vector of $S$ against the
rank vector of any target variable, the squared Spearman correlation of $S$ with any
target is at most the ratio of the tied midrank variance to the untied variance, which
is exactly $\operatorname{ceil}(L)$. The bound is attained when the target is a
strictly monotone function of $S$ with untied values within blocks, so
$\operatorname{ceil}$ is the exact supremum, not merely an upper bound. Throughout,
"ceiling" means $\operatorname{ceil}(L)$ in squared units and $\rho_{\max}(L)$ in
correlation units.

Two degenerate checks: if all $m_j = 1$ then $\mathcal{T} = 0$ and
$\operatorname{ceil} = 1$; if $k = 1$ and $m_1 = n$ then $12\mathcal{T} = n^3 - n$ and
$\operatorname{ceil} = 0$.

---

## 3. The cube-sum calculus

The first theorem eliminates $\mathcal{T}$ in favour of a single, easily manipulated
integer.

**Theorem 3.1 (Tie correction in cube-sum form).** For every profile $L$,
$$12\,\mathcal{T}(L) \;=\; \operatorname{cube}(L) - \Sigma L .$$

*Proof.* Induct on the length of $L$. For $L = ()$ both sides vanish. For
$L = (m) \frown L'$, the correction splits as $\mathcal{T}((m)\frown L') =
\frac{m^3-m}{12} + \mathcal{T}(L')$, while $\operatorname{cube}$ and $\Sigma$ split
additively as $m^3 + \operatorname{cube}(L')$ and $m + \Sigma L'$. Apply the induction
hypothesis and add. $\square$

**Theorem 3.2 (Tie-attenuation law).** For every profile $L$ with $n = \Sigma L \ge 2$,
$$\operatorname{ceil}(L) \;=\; 1 - \frac{\operatorname{cube}(L) - n}{n^3 - n}.$$

*Proof.* Substitute Theorem 3.1 into Definition 2.4. $\square$

Theorem 3.2 already isolates the design principle: **at fixed sample size, the ceiling
depends on the statistic only through its cube sum**. All semantic content of the
statistic — arithmetic, combinatorial, cryptographic — enters through this one scalar.

**Theorem 3.3 (Cube-sum monotonicity).** Let $L, M$ be profiles with $\Sigma L = \Sigma M
= n \ge 2$ and $\operatorname{cube}(L) \le \operatorname{cube}(M)$. Then
$$\operatorname{ceil}(M) \;\le\; \operatorname{ceil}(L).$$

*Proof.* By Theorem 3.2 the difference is
$$\operatorname{ceil}(L) - \operatorname{ceil}(M)
= \frac{\operatorname{cube}(M) - \operatorname{cube}(L)}{n^3 - n},$$
and the denominator is positive since $n \ge 2$. $\square$

**Corollary 3.4 (Coarsening lowers the ceiling).** If $M$ is obtained from $L$ by
merging two blocks, i.e. replacing entries $a, b$ by the single entry $a+b$, then
$\operatorname{ceil}(M) \le \operatorname{ceil}(L)$, with strict inequality whenever
$a, b \ge 1$.

*Proof.* $\Sigma$ is unchanged, and $(a+b)^3 = a^3 + b^3 + 3ab(a+b) \ge a^3 + b^3$ with
equality only if $ab(a+b) = 0$. Apply Theorem 3.3. $\square$

Corollary 3.4 is the engine of §7. Informally: *a statistic can never be improved, in
the resolution sense, by forgetting how it distinguishes two of its values.*

---

## 4. The two profiles

### 4.1 The dyadic profile

**Definition 4.1.** For $b \ge 1$ the *dyadic profile* at bit-length $b$ is
$$D_b \;=\; \bigl(2^{b-1},\, 2^{b-2},\, \dots,\, 2,\, 1,\, 1\bigr),$$
the tie profile of $T = v_2$ on the residues modulo $N = 2^b$: exactly $N/2^{k+1}$ of
them have $v_2 = k$ for $0 \le k \le b-1$, and one (namely $0$) has valuation $\ge b$.
Thus $\Sigma D_b = N$.

**Proposition 4.2 (Dyadic ceiling).** With $N = 2^b$,
$$\operatorname{ceil}(D_b) \;=\; \frac{6}{7}\left(1 + \frac{1}{N(N+1)}\right).$$

*Proof.* The cube sum is $\sum_{k=0}^{b-1} 8^{\,b-1-k} + 1 = \frac{N^3-1}{7} + 1 =
\frac{N^3 + 6}{7}$. Hence by Theorem 3.2
$$\operatorname{ceil}(D_b) = 1 - \frac{N^3 - 7N + 6}{7(N^3-N)}
= 1 - \frac{(N-1)(N-2)(N+3)}{7N(N-1)(N+1)}
= 1 - \frac{(N-2)(N+3)}{7N(N+1)} .$$
Expanding the numerator, $7N(N+1) - (N^2+N-6) = 6(N^2+N+1)$, so
$\operatorname{ceil}(D_b) = \frac{6(N^2+N+1)}{7N(N+1)} = \frac{6}{7}(1 + \frac{1}{N(N+1)})$.
$\square$

Immediate consequences: $\operatorname{ceil}(D_b) > 6/7$ for every $b$;
$\operatorname{ceil}(D_b)$ is strictly decreasing in $b$; and
$\operatorname{ceil}(D_b) - 6/7 < 4^{-b}$. At $b = 48$,
$$\operatorname{ceil}(D_{48}) \in \bigl(6/7,\ 6/7 + 10^{-14}\bigr),
\qquad \rho_{\max}(D_{48}) = 0.9258200997\ldots$$

The constant $6/7$ is the fixed point of the halving cascade: a geometric profile with
ratio $1/2$ has cube sum $\frac{1}{1 - 1/8} = \frac{8}{7}$ times its largest cube, i.e.
$\frac{1}{7}$ of $N^3$, destroying one seventh of the available resolution.

### 4.2 The quadratic-residue profile

**Definition 4.3.** For $m \ge 1$ set $Q_m := (m,\ m+1)$, with $\Sigma Q_m = 2m+1$ and
$\operatorname{cube}(Q_m) = m^3 + (m+1)^3$.

That $Q_m$ really is the tie profile of the quadratic-residue indicator modulo the prime
$p = 2m+1$ is the content of the following classical fact, for which we give the
character-sum proof because it is the argument that generalises.

**Theorem 4.4 (Arithmetic bridge).** Let $p$ be an odd prime. Then the number of
squares in $\mathbb{Z}/p$ (with $0$ counted as a square) exceeds the number of
non-squares by exactly one:
$$\#\{a : a \text{ is a square}\} = \#\{a : a \text{ is not a square}\} + 1 .$$
Equivalently, writing $p = 2m+1$: there are $m+1$ squares and $m$ non-squares, so the
tie profile of the quadratic-residue indicator is $Q_m$.

*Proof.* Let $\chi$ be the quadratic character of $\mathbb{Z}/p$, so $\chi(0) = 0$,
$\chi(a) = 1$ for $a$ a nonzero square, and $\chi(a) = -1$ for $a$ a non-square; this
trichotomy uses that the characteristic is not $2$. Split the full character sum along
the square/non-square partition:
$$\sum_{a \text{ square}} \chi(a) \;+\; \sum_{a \text{ non-square}} \chi(a)
\;=\; \sum_{a \in \mathbb{Z}/p} \chi(a) \;=\; 0,$$
the vanishing being the standard orthogonality of the nontrivial character $\chi$
against the trivial one. The second sum equals $-\,\#\{\text{non-squares}\}$. The first
sum is $\#\{\text{squares}\} - 1$, because $0$ is a square contributing $\chi(0)=0$
instead of $1$, while every other square contributes $+1$. Hence
$\#\{\text{squares}\} - 1 - \#\{\text{non-squares}\} = 0$. Since the two classes
partition $\mathbb{Z}/p$ and $|\mathbb{Z}/p| = p = 2m+1$, the cardinalities are $m+1$
and $m$. $\square$

---

## 5. The prime-independence law

**Theorem 5.1 (Prime independence).** For every $m \ge 1$,
$$\operatorname{ceil}(Q_m) \;=\; \frac{3}{4} \qquad \text{exactly},$$
hence $\rho_{\max}(Q_m) = \sqrt{3}/2 = 0.8660254\ldots$ for **every** odd prime modulus
$p = 2m+1$.

*Proof.* The key identity is the factorisation
$$m^3 + (m+1)^3 \;=\; (2m+1)\,(m^2+m+1),$$
verified by expanding the right side to $2m^3+3m^2+3m+1$, which is exactly
$m^3 + (m^3+3m^2+3m+1)$. Hence, with $n = 2m+1$,
$$\operatorname{cube}(Q_m) - n \;=\; (2m+1)(m^2+m+1) - (2m+1)
\;=\; (2m+1)\,m(m+1),$$
while
$$n^3 - n \;=\; (2m+1)\bigl((2m+1)^2-1\bigr) \;=\; (2m+1)\cdot 4m(m+1).$$
The two expressions share the factor $(2m+1)\,m(m+1)$, which is nonzero for $m \ge 1$,
so their quotient is exactly $\tfrac14$ with the modulus cancelling identically. By
Theorem 3.2, $\operatorname{ceil}(Q_m) = 1 - \tfrac14 = \tfrac34$. $\square$

The whole content of the theorem is the factorisation $m^3+(m+1)^3 = (2m+1)(m^2+m+1)$:
the numerator of the tie correction and the denominator $n^3-n$ turn out to be
proportional, with proportionality constant $4$ independent of $m$.

**Remark 5.2.** The structural reason is transparent once the factorisation is in hand.
For a two-block profile $(\alpha n, (1-\alpha)n)$ with $\alpha \to 1/2$, the ceiling
tends to $1 - (\alpha^3 + (1-\alpha)^3) = 3/4$ at $\alpha = 1/2$; the Legendre split is
$\alpha = m/(2m+1)$, off-balance by exactly one element, and the exact
factorisation shows the finite-$m$ correction vanishes identically rather than merely
being $O(m^{-2})$. This exact cancellation is special to the split $(m, m+1)$.

**Corollary 5.3.** For all $m \ge 1$ and $b \ge 1$,
$$\operatorname{ceil}(Q_m) = \tfrac34 \;<\; \tfrac67 \;<\; \operatorname{ceil}(D_b).$$
The bare quadratic-residue count has strictly lower resolution than the trailing-zero
dial at *every* bit-length and *every* odd prime modulus. No choice of prime, and no
amount of data, alters this.

---

## 6. The multiplicative tower law

Multiple primes can be combined. By the Chinese Remainder Theorem the joint statistic
$x \mapsto \bigl(\chi_{p_1}(x), \dots, \chi_{p_r}(x)\bigr)$ over distinct odd primes has
level sets indexed by the product of the individual level-set families, with
cardinalities the products of the individual block sizes.

**Definition 6.1 (Product profile).** For profiles $A, B$ set
$$A \otimes B \;:=\; \bigl(a b\bigr)_{a \in A,\ b \in B},$$
the profile of all pairwise products, with $|A|\cdot|B|$ entries.

**Lemma 6.2.** $\Sigma(A \otimes B) = (\Sigma A)(\Sigma B)$ and
$\operatorname{cube}(A \otimes B) = \operatorname{cube}(A)\cdot\operatorname{cube}(B)$.

*Proof.* Both follow by distributing over $A$ and using
$\Sigma(aB) = a\,\Sigma B$, $\operatorname{cube}(aB) = a^3 \operatorname{cube}(B)$,
which are immediate inductions on $B$. $\square$

**Definition 6.3 (Legendre vector profile).** For a list $m_1, \dots, m_r$ with each
$p_i = 2m_i+1$ prime, set
$$V(m_1,\dots,m_r) \;:=\; Q_{m_1} \otimes \cdots \otimes Q_{m_r}\ ,$$
the tie profile of the joint Legendre *vector* on a full residue system modulo
$N = \prod_i p_i$.

**Theorem 6.4 (Multiplicative tower law).** With $N = \prod_{i}(2m_i+1) \ge 2$ and
$C = \prod_i \bigl(m_i^3 + (m_i+1)^3\bigr)$,
$$\operatorname{ceil}\bigl(V(m_1,\dots,m_r)\bigr) \;=\; 1 - \frac{C - N}{N^3 - N}.$$

*Proof.* By Lemma 6.2 and induction, $\Sigma V = \prod_i \Sigma Q_{m_i} = N$ and
$\operatorname{cube}(V) = \prod_i \operatorname{cube}(Q_{m_i}) = C$. Apply Theorem 3.2.
$\square$

Both constituents are multiplicative across CRT factors, so the ceiling factorises
**with no interaction term**. Using the identity from Theorem 5.1, $C = \prod_i p_i
\cdot \prod_i (m_i^2+m_i+1)$, so
$$\frac{C}{N^3} = \prod_i \frac{m_i^2+m_i+1}{(2m_i+1)^2} = \prod_i \frac{p_i^2+3}{4p_i^2},$$
a clean per-prime factor. For $p=3$ this is $1/3$; for $p=5$, $7/25$; for $p=7$,
$13/49$; and it decreases to $1/4$ as $p \to \infty$.

**Example 6.5.** For primes $3$ and $5$ ($m = 1, 2$): $V = (2,3,4,6)$, $N = 15$,
$C = 8+27+64+216 = 315$, so
$$\operatorname{ceil}(V) = 1 - \frac{315-15}{3375-15} = 1 - \frac{300}{3360} = \frac{51}{56} = 0.910714\ldots$$

---

## 7. The counting collapse

A practitioner combining $r$ Legendre symbols is likely to *sum* them: record how many
of the $r$ tests report "square". This coarsens the vector statistic, and Corollary 3.4
predicts a loss. We make this precise for arbitrary lists of primes.

**Definition 7.1 (Convolution step).** For $a, b \in \mathbb{N}$ and a profile $L =
(c_0, c_1, \dots)$ (indexed by count value), set
$$\mathrm{mB}_{a,b}(L) \;:=\; \text{the coefficient list of } (b + a z)\cdot \textstyle\sum_i c_i z^i .$$
Concretely $\mathrm{mB}_{a,b}(())=()$ and
$\mathrm{mB}_{a,b}\bigl((c)\frown L\bigr) = (bc) \frown \mathrm{addHead}\bigl(ac,\ \mathrm{mB}_{a,b}(L)\bigr)$,
where $\mathrm{addHead}(x, \cdot)$ adds $x$ to the leading entry (creating it if the list
is empty).

**Definition 7.2 (Legendre count profile).** For $m_1, \dots, m_r$ set
$$K(m_1,\dots,m_r) \;:=\; \mathrm{mB}_{m_1, m_1+1}\Bigl(\cdots \mathrm{mB}_{m_r, m_r+1}\bigl((1)\bigr)\cdots\Bigr),$$
the coefficient list of $\prod_i \bigl((m_i+1) + m_i z\bigr)$. Its $j$-th entry counts
the residues modulo $N$ at which exactly $j$ of the $r$ symbols report "non-square".

**Lemma 7.3.** $\Sigma K(m_1,\dots,m_r) = \prod_i (2m_i+1) = N = \Sigma V(m_1,\dots,m_r)$.

*Proof.* Evaluate the generating polynomial at $z = 1$: each factor contributes
$(m_i+1)+m_i = 2m_i+1$. $\square$

**Lemma 7.4 (Cube superadditivity of merging).** For $x \in \mathbb{N}$ and any profile
$L$, $x^3 + \operatorname{cube}(L) \le \operatorname{cube}(\mathrm{addHead}(x,L))$.

*Proof.* If $L$ is empty both sides agree. Otherwise $L = (y)\frown t$ and the right side
is $(x+y)^3 + \operatorname{cube}(t) = x^3+y^3+3xy(x+y)+\operatorname{cube}(t)$. $\square$

**Lemma 7.5 (Convolution step is cube-superadditive).** For all $a,b$ and every profile
$L$,
$$(a^3+b^3)\,\operatorname{cube}(L) \;\le\; \operatorname{cube}\bigl(\mathrm{mB}_{a,b}(L)\bigr).$$

*Proof.* Induction on $L$. Empty case trivial. For $L = (c)\frown L'$,
$$\operatorname{cube}\bigl(\mathrm{mB}_{a,b}(L)\bigr)
= (bc)^3 + \operatorname{cube}\bigl(\mathrm{addHead}(ac,\ \mathrm{mB}_{a,b}(L'))\bigr)
\;\ge\; b^3c^3 + a^3c^3 + \operatorname{cube}\bigl(\mathrm{mB}_{a,b}(L')\bigr)$$
by Lemma 7.4, and the induction hypothesis bounds the last term below by
$(a^3+b^3)\operatorname{cube}(L')$. Summing,
$$\operatorname{cube}\bigl(\mathrm{mB}_{a,b}(L)\bigr) \ge (a^3+b^3)\bigl(c^3 + \operatorname{cube}(L')\bigr) = (a^3+b^3)\operatorname{cube}(L).\ \square$$

**Proposition 7.6.** $\operatorname{cube}\bigl(V(m_1,\dots,m_r)\bigr) \le
\operatorname{cube}\bigl(K(m_1,\dots,m_r)\bigr)$ for every list of $m_i$.

*Proof.* Induction on $r$. For $r=0$ both are $1$. For the step, by Lemma 6.2
$\operatorname{cube}(V(m\frown \mathbf{m}')) = (m^3+(m+1)^3)\operatorname{cube}(V(\mathbf{m}'))$,
which by the induction hypothesis is at most
$(m^3+(m+1)^3)\operatorname{cube}(K(\mathbf{m}'))$, which by Lemma 7.5 with
$a = m$, $b = m+1$ is at most $\operatorname{cube}(\mathrm{mB}_{m,m+1}(K(\mathbf{m}'))) =
\operatorname{cube}(K(m \frown \mathbf{m}'))$. $\square$

**Theorem 7.7 (Counting collapse).** For every list of odd primes $p_i = 2m_i+1$ with
$N = \prod p_i \ge 2$,
$$\operatorname{ceil}\bigl(K(m_1,\dots,m_r)\bigr) \;\le\; \operatorname{ceil}\bigl(V(m_1,\dots,m_r)\bigr).$$

*Proof.* The two profiles have equal sample size (Lemma 7.3) and the count profile has
the larger cube sum (Proposition 7.6); apply Theorem 3.3. $\square$

**Example 7.8 (Strictness at two primes).** For $p = 3, 5$ the count profile is
$K(1,2) = (6,7,2)$ with $\operatorname{cube} = 216+343+8 = 567$ and $N=15$, giving
$$\operatorname{ceil}(K(1,2)) = 1 - \frac{567-15}{3360} = \frac{117}{140} = 0.835714\ldots
\;<\; \frac{51}{56} = 0.910714\ldots = \operatorname{ceil}(V(1,2)).$$
Summing the two symbols costs $0.075$ of squared ceiling.

**Example 7.9 (Three primes, counted).** For $p = 3,5,7$: $K(1,2,3) = (24,46,29,6)$,
$N = 105$, $\operatorname{cube} = 135765$, so
$$\operatorname{ceil}(K(1,2,3)) = 1 - \frac{135660}{1157520} = \frac{2433}{2756} = 0.882801\ldots$$

---

## 8. The crossover hierarchy and the replicated tower

**Theorem 8.1 (Crossover hierarchy at bit-length 48).** With
$\operatorname{ceil}(D_{48}) \in (6/7,\ 6/7 + 10^{-14})$:
$$\operatorname{ceil}(Q_1) = \tfrac34 \;<\; \operatorname{ceil}(K(1,2)) = \tfrac{117}{140}
\;<\; \operatorname{ceil}(D_{48}) \;<\; \operatorname{ceil}(K(1,2,3)) = \tfrac{2433}{2756}
\;<\; \operatorname{ceil}(V(1,2)) = \tfrac{51}{56}.$$

*Proof.* Numerically $0.7500 < 0.8357 < 0.857142857\ldots < 0.8828 < 0.9107$, and the
bracketing of $\operatorname{ceil}(D_{48})$ from Proposition 4.2 separates the middle
comparisons with margin exceeding $10^{-2}$. $\square$

**Reading.** Three Legendre symbols are required before a QR *count* can, on tie
geometry alone, out-resolve the trailing-zero dial at bit-length $48$; but only two
symbols suffice if they are kept as a *vector*. The counting collapse is precisely what
shifts the crossover from two symbols to three.

The QR baseline is therefore capped only in its bare, one-symbol form. The following
closed form makes the escape explicit.

**Theorem 8.2 (Replicated-symbol tower).** Let $r \ge 1$ and take $r$ independent
Legendre symbols at the prime $3$, kept as a vector, so the profile is
$V(1,\dots,1)$ ($r$ copies). Then
$$\operatorname{ceil}\bigl(V(\underbrace{1,\dots,1}_{r})\bigr)
\;=\; 1 - \frac{9^r - 3^r}{27^r - 3^r} \;\ge\; 1 - \frac{2}{3^{\,r}} .$$

*Proof.* By Lemma 6.2, $N = 3^r$ and $C = (1^3+2^3)^r = 9^r$; Theorem 6.4 with
$N^3 = 27^r$ gives the closed form. For the bound, write $x = 3^r \ge 3$; then
$$\frac{2}{x} - \frac{x^2 - x}{x^3 - x}
= \frac{2(x^3-x) - x(x^2-x)}{x(x^3-x)}
= \frac{x^3 + x^2 - 2x}{x(x^3-x)}
= \frac{x^2+x-2}{x^3-x} \;\ge\; 0$$
for $x \ge 1$, using $9^r = x^2$, $27^r = x^3$. $\square$

**Corollary 8.3.** Two Legendre symbols at the prime $3$, kept as a vector, already
attain ceiling $1 - \frac{81-9}{729-9} = \frac{9}{10} = 0.9$, strictly above
$\operatorname{ceil}(D_{48})$.

The convergence is geometric: $r$ symbols reach within $2\cdot 3^{-r}$ of perfect
resolution. Resolution is bought by *recording more*, not by *choosing better primes*.

---

## 9. The gap law: the recorded advantage is not an artefact

We now convert squared ceilings into correlation units and confront the record.

**Proposition 9.1.** $\rho_{\max}(D_{48}) < 0.9259$ and $\rho_{\max}(Q_m) > 0.866$ for
every $m \ge 1$.

*Proof.* $\operatorname{ceil}(D_{48}) < 6/7 + 10^{-14} < 0.9259^2 = 0.85728\ldots$ and
$\operatorname{ceil}(Q_m) = 3/4 > 0.866^2 = 0.749956$; take square roots, which are
monotone on $[0,\infty)$. $\square$

**Theorem 9.2 (Gap law).** For every $m \ge 1$,
$$\rho_{\max}(D_{48}) - \rho_{\max}(Q_m) \;<\; 0.06 .$$
Numerically the exact value is $\sqrt{6/7 + \varepsilon} - \sqrt{3/4} = 0.0597947\ldots$
with $\varepsilon < 10^{-28}$.

*Proof.* Immediate from Proposition 9.1: $0.9259 - 0.866 = 0.0599 < 0.06$. $\square$

**Theorem 9.3 (The recorded gap forces slack).** Let $t$ be the dial's recorded
correlation and $q$ the baseline's, on the same sample at bit-length $48$ with an odd
prime modulus $p = 2m+1$. Suppose $t \le \rho_{\max}(D_{48})$ (i.e. the dial respects
its own ceiling, which it must) and $t - q \ge 0.09$ (the recorded advantage). Then
$$q \;\le\; \rho_{\max}(Q_m) - 0.03 .$$

*Proof.* $q \le t - 0.09 \le \rho_{\max}(D_{48}) - 0.09 < \rho_{\max}(Q_m) + 0.06 - 0.09
= \rho_{\max}(Q_m) - 0.03$, using Theorem 9.2. $\square$

**Interpretation.** Tie granularity can account for at most $0.06$ of the recorded
$0.09$–$0.13$ advantage — at most two thirds of the smallest recorded gap, and under
half of the largest. The residual is not geometry. The baseline reading must sit at
least $0.03$ below its own physically attainable maximum: the Legendre symbol is not
merely coarse here, it is genuinely less coupled to the downstream rate than the 2-adic
valuation is.

**Proposition 9.4 (Readings are admissible).** With the recorded top reading
$t = 0.801$ and advantage in $[0.09, 0.13]$, every compatible baseline value
$q \in [0.671,\, 0.711]$ satisfies $q^2 \le 0.5055 < 3/4 = \operatorname{ceil}(Q_m)$.
Likewise every recorded dial value satisfies $t^2 \le 0.801^2 = 0.6416 < 6/7 <
\operatorname{ceil}(D_{48})$. Both statistics' readings are therefore consistent with
their ceilings; the analysis above is not vacuous.

---

## 10. Calibration consequences

**Theorem 10.1 (Band-saturation asymmetry).** Let $B = 0.85$ be the upper edge of the
validation band $[0.55, 0.85]$. Then for every $m \ge 1$,
$$\rho_{\max}(Q_m) - B \;<\; 0.017, \qquad \rho_{\max}(D_{48}) - B \;>\; 0.07 .$$

*Proof.* $\rho_{\max}(Q_m) = \sqrt{3}/2 < 0.8661$, so the first difference is below
$0.0161$. And $\rho_{\max}(D_{48}) > \sqrt{6/7} > 0.9258$, so the second exceeds
$0.0758$. $\square$

The band leaves the baseline under $2\%$ of headroom and the dial over $7.5\%$: it is
nearly saturating for one statistic and comfortable for the other. **A validation band
calibrated on one statistic is not transportable to a statistic with a different
ceiling.** This is a general methodological point: fixed acceptance intervals impose
unequal standards across estimators of unequal intrinsic resolution. The remedy is to
report *ceiling-normalised* correlations $\rho / \rho_{\max}$, which for the record here
read $0.777/0.9258 = 0.839$, $0.755/0.9258 = 0.815$, $0.801/0.9258 = 0.865$.

**Theorem 10.2 (Envelope flatness).** Across the recorded deployment envelope
$b \in [44, 52]$, the dyadic ceiling is strictly decreasing in $b$, yet
$$\operatorname{ceil}(D_{44}) - \operatorname{ceil}(D_{52}) \;<\; 2^{-80}.$$

*Proof.* Strict antitonicity follows from Proposition 4.2 since $N(N+1)$ is strictly
increasing. For the bound, $\operatorname{ceil}(D_{44}) - 6/7 < 4^{-44} = 2^{-88}$ and
$\operatorname{ceil}(D_{52}) > 6/7$, so the difference is under $2^{-88} < 2^{-80}$.
$\square$

**Consequence.** The empirically observed bit-length dependence of the dial across
bit-lengths $44$–$52$ — measured in points of correlation — cannot be tie geometry,
which moves by less than $10^{-24}$. Any bit-length effect in the data is substantive.

---

## 11. Algorithms

All quantities above are exactly computable in rational arithmetic. Three routines
suffice.

**Algorithm A (Ceiling of a profile).** Input a profile $L$; compute $n = \Sigma L$ and
$c = \operatorname{cube}(L)$; return $1 - (c-n)/(n^3-n)$ as an exact rational. Cost
$O(k)$ big-integer operations for a profile of $k$ blocks.

**Algorithm B (Legendre vector and count profiles).** Given primes $p_i = 2m_i+1$,
build the vector profile by iterated product $Q_{m_1}\otimes\cdots\otimes Q_{m_r}$
($2^r$ entries, cost $O(2^r)$), and the count profile by convolving the polynomials
$(m_i+1) + m_i z$ ($r+1$ entries, cost $O(r^2)$). Feed both to Algorithm A. The
count profile is exponentially cheaper to build and provably no better.

**Algorithm C (Gap audit).** Given a bit-length $b$, an odd prime $p$, a recorded dial
correlation $t$ and baseline correlation $q$: compute $\rho_{\max}(D_b)$ and
$\rho_{\max}(Q_{(p-1)/2}) = \sqrt{3}/2$; report the *geometric budget*
$G = \rho_{\max}(D_b) - \rho_{\max}(Q_m)$ and the *forced slack*
$S = (t-q) - G$. If $S > 0$ the advantage exceeds anything tie geometry can produce,
and the baseline lies at least $S$ below its ceiling.

Applied to the record at $b=48$: $G = 0.05979$, and for the three seeds with an
advantage of $0.09$ the forced slack is $S \ge 0.0302$, rising to $S \ge 0.0702$ at an
advantage of $0.13$.

---

## 12. Discussion

### 12.1 What is and is not established

The results are about *resolution*, not about the mechanism linking $v_2$ to the
downstream rate. We prove that the recorded advantage cannot be explained by tie
granularity; we do not identify what does explain it. That question — why the 2-adic
valuation of a uniform draw should couple to a downstream success rate at all — remains
open, and is arguably the more interesting one.

Conversely, the negative results are unconditional and complete. The bare
quadratic-residue count's ceiling of exactly $3/4$ holds for every odd prime with no
error term, and $3/4 < 6/7$ at every bit-length. The counting collapse holds for every
finite list of primes.

### 12.2 The two-block rigidity

Theorem 5.1 exposes a rigidity worth naming: the ceiling of a two-valued statistic is a
pure function of its class-mass split, so *all* arithmetic content of the indicator —
reciprocity, character-sum estimates, equidistribution — enters only through a single
scalar bias. Two indicators with wildly different arithmetic depth but the same split
have identical ceilings. In particular, no theorem about the pseudo-randomness of
Legendre symbols can raise the ceiling of a single Legendre symbol above $3/4$.

### 12.3 Vector versus count: a design rule

The counting collapse yields a practical prescription. When combining several binary
arithmetic probes into a composite baseline, retain the joint vector rather than the
count whenever downstream cost permits. The vector profile has $2^r$ blocks and the
count only $r+1$, and the difference is real: at two primes, $0.9107$ versus $0.8357$
in squared units. The count is exponentially cheaper to store; the price is a strictly
lower ceiling, quantified exactly by Theorem 7.7.

### 12.4 Reporting recommendation

Theorem 10.1 argues that raw correlation bands are the wrong unit for cross-statistic
comparison. Report ceiling-normalised correlation $\rho/\rho_{\max}$, or equivalently
report $\rho_{\max}$ alongside $\rho$. This makes the geometric budget explicit and
prevents the silent double standard that a fixed band imposes.

---

## 13. Future work

1. **Sharp two-block cliff for arithmetic indicators.** Conjecture: every *balanced*
   arithmetic indicator — one whose two classes differ in size by at most one on a full
   residue system modulo $n$ — has ceiling in $\bigl[3/4,\ 3/4 + 3/(4n^2)\bigr]$, with
   equality $3/4$ exactly on the odd-prime Legendre indicator; and no arithmetic
   indicator with $k$ classes can exceed $1 - 1/k^2$ on a modulus supporting
   equidistribution. The machinery of §3 already reduces such comparisons to a cube-sum
   inequality.
2. **Multiplicative ceiling spectrum.** For squarefree $M = p_1\cdots p_r$ the
   joint-Legendre ceiling is $1 - \bigl(\prod_i \frac{p_i^2+3}{4p_i^2}\cdot M^3 - M\bigr)/(M^3-M)$,
   so the achievable ceilings form the multiplicative semigroup generated by
   $\{(p^2+3)/(4p^2)\}$. Conjecture: this semigroup is dense in $(0,1)$, hence for every
   target $t \in (3/4,1)$ there is a squarefree modulus whose Legendre vector has
   ceiling within $10^{-6}$ of $t$. The tie functional is multiplicative across CRT
   factors and so is the sample size, so the ceiling factorises with no interaction.
3. **Capped dials.** Truncating $T$ at a cap $c$ merges the tail blocks; the resulting
   ceiling is computable from Proposition 4.2 by a single merge, and the trade-off
   between register width and resolution can be optimised exactly.
4. **Mixed towers.** Combining a dyadic dial with a Legendre vector gives a product
   profile whose ceiling is computable by Lemma 6.2. Determining the cheapest composite
   statistic reaching a target ceiling is a clean discrete optimisation over
   $\{2\} \cup \{\text{odd primes}\}$ with multiplicative cost.
5. **Beyond Spearman.** Kendall's $\tau_b$ and the Goodman–Kruskal $\gamma$ carry their
   own tie corrections; whether an analogous exact prime-independence law holds for them
   is open.

---

## 14. Summary of results

| Object | Profile | Ceiling $\rho^2$ | $\rho_{\max}$ |
|---|---|---|---|
| Trailing-zero dial, $b$ bits | $(2^{b-1},\dots,2,1,1)$ | $\frac{6}{7}\bigl(1+\frac{1}{N(N+1)}\bigr)$, $N=2^b$ | — |
| Trailing-zero dial, $b=48$ | — | $0.857142857\ldots$ | $0.9258201$ |
| One Legendre symbol, any odd $p$ | $(m,m+1)$ | $3/4$ exactly | $0.8660254$ |
| Two symbols ($3,5$), counted | $(6,7,2)$ | $117/140$ | $0.9141$ |
| Three symbols ($3,5,7$), counted | $(24,46,29,6)$ | $2433/2756$ | $0.9396$ |
| Two symbols ($3,5$), vector | $(2,3,4,6)$ | $51/56$ | $0.9543$ |
| $r$ symbols at $3$, vector | — | $1-\frac{9^r-3^r}{27^r-3^r} \ge 1-2\cdot 3^{-r}$ | — |

Key inequalities: $\;3/4 < 117/140 < \operatorname{ceil}(D_{48}) < 2433/2756 < 51/56$;
$\;\rho_{\max}(D_{48}) - \rho_{\max}(Q_m) < 0.06$ for all odd primes; recorded advantage
$\ge 0.09$ forces baseline slack $\ge 0.03$; and the band edge $0.85$ leaves $<0.017$ of
room for the baseline versus $>0.07$ for the dial.
