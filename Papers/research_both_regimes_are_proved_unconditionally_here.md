# Two Regimes for the 2-Torsion of a Quadratic Twist Family, and the Collapse of the 3-Division Count

**Author:** Aristotle
**Date:** 2026-09-04

---

## Abstract

Let $p$ be an odd prime and let $a \in \mathbb{F}_p^{\times}$. We study the quadratic twist family of elliptic curves
$$E_{a,d} : y^2 = x^3 - a d^2 x, \qquad d \in \mathbb{F}_p^{\times},$$
and prove a complete, unconditional dichotomy for its 2-torsion. The subgroup $E_{a,d}(\mathbb{F}_p)[2]$ is a Klein four-group $\mathbb{Z}/2 \times \mathbb{Z}/2$ when $a$ is a quadratic residue mod $p$, and is cyclic of order two otherwise — *uniformly in the twisting parameter $d$*, because $a d^2$ is a square exactly when $a$ is. Consequently the summed 2-torsion order over the family equals $4(p-1)$ in the split regime and $2(p-1)$ in the non-split regime, with no intermediate value possible. Specialising the arithmetic input to the classical reciprocity laws yields explicit congruence criteria: for $a = 3$ the split classes are $p \equiv 1, 11 \pmod{12}$; for $a = 2$ they are $p \equiv 1, 7 \pmod 8$; for $a = -1$ they are $p \equiv 1 \pmod 4$. Both regimes are proved unconditionally and in full, together with the group-theoretic upgrade (the torsion subgroup is genuinely Klein four, not merely of order four) and the Lagrange consequence $4 \mid \#E_{a,d}(\mathbb{F}_p)$ in the split regime, $2 \mid \#E_{a,d}(\mathbb{F}_p)$ always.

We then contrast this with the analogous computation one level up. For the $j = 0$ family $C_b : y^2 = x^3 + b$, $b \in \mathbb{F}_p^{\times}$, the 3-division polynomial is $\psi_3^{(b)}(x) = 3x^4 + 12bx = 3x(x^3 + 4b)$, whose root count over $\mathbb{F}_p$ oscillates between $1$, $2$ and $4$ according to $p \bmod 3$ and the cubic character of $-4b$. Nevertheless the summed count is *regime-independent*:
$$\sum_{b \in \mathbb{F}_p^{\times}} \#\{x \in \mathbb{F}_p : \psi_3^{(b)}(x) = 0\} = 2(p-1)$$
for every prime $p \neq 2, 3$. The proof is a fibre-counting bijection over the variable $x$ rather than over $b$. The juxtaposition of the two theorems isolates precisely which input in such a summed count is arithmetic (a quadratic character, hence a congruence condition) and which is purely combinatorial (a change of variables that averages the arithmetic away).

**Keywords:** elliptic curves over finite fields, 2-torsion, Klein four-group, quadratic twist, quadratic reciprocity, division polynomial, fibre counting, cubic residues.

---

## 1. Introduction

### 1.1 The question

For an elliptic curve $E$ over a finite field $\mathbb{F}_p$, the torsion subgroups $E(\mathbb{F}_p)[n]$ encode a great deal of arithmetic. The case $n = 2$ is the most transparent: in odd characteristic a curve in short Weierstrass form $y^2 = f(x)$, with $f$ a separable cubic, has
$$E(\mathbb{F}_p)[2] = \{\mathcal{O}\} \cup \{(x, 0) : f(x) = 0\},$$
because negation on such a curve is $(x,y) \mapsto (x, -y)$, so a point is 2-torsion precisely when $y = -y$, that is $y = 0$. Thus the group structure of $E[2]$ is *literally* the factorisation type of $f$ over $\mathbb{F}_p$: three roots give a Klein four-group, one root gives $\mathbb{Z}/2$, and no roots is impossible for a cubic over a finite field only insofar as a cubic always has at least one root when it factors — in general a cubic over $\mathbb{F}_p$ either has one root or three (counted without multiplicity, in the separable case), so $\#E[2] \in \{2, 4\}$.

The families studied here are chosen so that this factorisation is completely explicit.

### 1.2 The two families

**The twist family (Sections 2–5).** Fix $a \in \mathbb{F}_p^\times$ and put
$$E_{a,d} : y^2 = x^3 - a d^2 x, \qquad d \in \mathbb{F}_p^\times.$$
These are the quadratic twists of $E_{a,1}$ by $d$; they all have $j$-invariant $1728$, all have full complex multiplication by $\mathbb{Z}[i]$ over $\overline{\mathbb{F}_p}$, and their point counts vary substantially with $d$. Our results say the 2-torsion does *not* vary with $d$ at all.

**The $j = 0$ family (Section 6).** Put
$$C_b : y^2 = x^3 + b, \qquad b \in \mathbb{F}_p^\times,$$
with $j$-invariant $0$, complex multiplication by $\mathbb{Z}[\zeta_3]$. Its 3-division polynomial is
$$\psi_3^{(b)}(x) = 3x^4 + 12 b x,$$
whose roots are the $x$-coordinates of the affine 3-torsion. Here the count over $\mathbb{F}_p$ is genuinely erratic — and yet the sum over $b$ is not.

### 1.3 Statement of the main results

We collect the four theorems that form the backbone of the paper. All are unconditional; $p$ always denotes a prime.

> **Theorem A (Two-regime law for the 2-torsion).** Let $p \neq 2$ and $a \in \mathbb{F}_p^\times$. For every $d \in \mathbb{F}_p^\times$,
> $$\#E_{a,d}(\mathbb{F}_p)[2] = \begin{cases} 4, & a \text{ a square in } \mathbb{F}_p, \\ 2, & \text{otherwise,}\end{cases}$$
> and consequently
> $$\Sigma_a(p) \;:=\; \sum_{d \in \mathbb{F}_p^\times} \#E_{a,d}(\mathbb{F}_p)[2] \;=\; \begin{cases} 4(p-1), & a \text{ a square},\\ 2(p-1), & \text{otherwise.}\end{cases}$$

> **Theorem B (Group-theoretic form).** With $p \neq 2$ and $c = a d^2 \neq 0$: if $c$ is a square in $\mathbb{F}_p$, the 2-torsion subgroup of $y^2 = x^3 - cx$ over $\mathbb{F}_p$ is isomorphic to $\mathbb{Z}/2 \times \mathbb{Z}/2$; if $c$ is a non-square, it is cyclic of order two and in particular contains no Klein four-subgroup. As a Lagrange consequence, $4 \mid \#E(\mathbb{F}_p)$ in the split regime and $2 \mid \#E(\mathbb{F}_p)$ in every regime.

> **Theorem C (Reciprocity input, and the congruence criteria).** For a prime $p \notin \{2,3\}$, $3$ is a square modulo $p$ if and only if $p \equiv 1$ or $11 \pmod{12}$. Hence
> $$\Sigma_3(p) = \begin{cases} 4(p-1), & p \equiv 1, 11 \pmod{12},\\ 2(p-1), & p \equiv 5, 7 \pmod{12}.\end{cases}$$
> Analogously, $\Sigma_2(p) = 4(p-1)$ iff $p \equiv 1, 7 \pmod 8$, and $\Sigma_{-1}(p) = 4(p-1)$ iff $p \equiv 1 \pmod 4$.

> **Theorem D (Regime-independence of the summed 3-division count).** For every prime $p \neq 2, 3$,
> $$\sum_{b \in \mathbb{F}_p^\times} \#\{x \in \mathbb{F}_p : \psi_3^{(b)}(x) = 0\} = 2(p-1),$$
> independently of the residue of $p$ modulo $3$ — even though for $p \equiv 2 \pmod 3$ every individual term equals $2$, while for $p \equiv 1 \pmod 3$ the individual terms take the values $1$ and $4$.

### 1.4 What the contrast means

Theorems A–C and Theorem D are structurally parallel: both are summed root counts of a division polynomial over a one-parameter family. But their content is entirely different.

In Theorem A the family parameter $d$ enters through $a d^2$, and squareness is invariant under multiplication by a nonzero square. The sum is therefore $(p-1)$ identical copies of a single arithmetic quantity, and the arithmetic — the Legendre symbol $\left(\tfrac{a}{p}\right)$, hence via reciprocity a congruence condition on $p$ — passes intact through the summation.

In Theorem D the family parameter $b$ enters through the translation $x^3 \mapsto x^3 + 4b$, and the map $x \mapsto -x^3/4$ sends $\mathbb{F}_p^\times$ *onto* the parameter space with total multiplicity $p-1$ regardless of its fibre structure. Summing therefore counts the domain rather than the image, and the cubic-residue arithmetic cancels identically.

The general moral: a summed fibre count over a family retains exactly those invariants that the family fails to average away. Detecting which invariants those are, family by family, is the interesting problem; Sections 5 and 6 do it in the two smallest cases and Section 8 conjectures the general shape.

---

## 2. Preliminaries

Throughout, $p$ is a prime and $\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$. We write $\mathbb{F}_p^\times = \mathbb{F}_p \setminus \{0\}$, of cardinality $p - 1$.

**Definition 2.1 (Square).** An element $c \in \mathbb{F}_p$ is a *square* if $c = s^2$ for some $s \in \mathbb{F}_p$. We write $\mathrm{Sq}(c)$ for this predicate. Note $\mathrm{Sq}(0)$ holds.

**Lemma 2.2 (Nonvanishing of small constants).** If $q$ is a prime and $p \neq q$, then the image of $q$ in $\mathbb{F}_p$ is nonzero.

*Proof.* $q \equiv 0$ in $\mathbb{F}_p$ means $p \mid q$; since both are prime this forces $p = q$. $\square$

In particular $2 \neq 0$ and $3 \neq 0$ in $\mathbb{F}_p$ for $p \notin \{2,3\}$, and then also $4 = 2 \cdot 2 \neq 0$ since $\mathbb{F}_p$ is a domain. These facts are used silently below.

**Definition 2.3 (Square-root set).** For $c \in \mathbb{F}_p$, let
$$\mathrm{Sqrt}(c) := \{x \in \mathbb{F}_p : x^2 = c\}.$$

**Lemma 2.4 (Cardinality of the square-root set).** Let $p \neq 2$ and $c \in \mathbb{F}_p$ with $c \neq 0$.
1. If $c$ is a square, $\#\mathrm{Sqrt}(c) = 2$.
2. If $c$ is not a square, $\#\mathrm{Sqrt}(c) = 0$.

*Proof.* (2) is immediate from the definitions. For (1), write $c = s^2$; then $s \neq 0$ since $c \neq 0$, and $s \neq -s$ because $2s = 0$ with $2 \neq 0$ would force $s = 0$. If $x^2 = c$ then $x \cdot x = s \cdot s$, and in a field $x^2 = s^2$ implies $x = \pm s$ (factor $x^2 - s^2 = (x-s)(x+s)$). Hence $\mathrm{Sqrt}(c) = \{s, -s\}$, of size two. $\square$

**Definition 2.5 (The curve).** For $c \in \mathbb{F}_p$ let $E_c$ be the Weierstrass curve with coefficients $(a_1, a_2, a_3, a_4, a_6) = (0,0,0,-c,0)$, i.e. the affine equation
$$E_c : y^2 = x^3 - c x,$$
together with a point at infinity $\mathcal{O}$. For $p \neq 2$ and $c \neq 0$ the discriminant $\Delta = 64 c^3$ is nonzero, so $E_c$ is a genuine elliptic curve and $E_c(\mathbb{F}_p)$ is a finite abelian group with identity $\mathcal{O}$.

**Definition 2.6 (2-torsion).** $E_c(\mathbb{F}_p)[2] := \{P \in E_c(\mathbb{F}_p) : P + P = \mathcal{O}\}$. This is a subgroup: it is closed under addition because the group is abelian, so $(P+Q)+(P+Q) = (P+P)+(Q+Q)$; it contains $\mathcal{O}$; and it is closed under negation.

---

## 3. The 2-division polynomial and the local count

**Definition 3.1 (2-division cubic).** For $c \in \mathbb{F}_p$ set
$$\psi_2^{(c)}(X) := X^3 - cX \in \mathbb{F}_p[X].$$
Its roots are exactly the $x$-coordinates of the affine 2-torsion points of $E_c$.

**Lemma 3.2 (Torsion criterion).** Let $p \neq 2$ and let $P = (x, y)$ be an affine point of $E_c(\mathbb{F}_p)$. Then $P + P = \mathcal{O}$ if and only if $y = 0$.

*Proof.* On a curve of the form $y^2 = f(x)$ (no $a_1, a_3$ terms) the negation map is $-(x, y) = (x, -y)$. Hence $P + P = \mathcal{O}$ iff $P = -P$ iff $y = -y$ iff $2y = 0$; since $2 \neq 0$ in $\mathbb{F}_p$ and $\mathbb{F}_p$ is a domain, this is $y = 0$. $\square$

**Proposition 3.3 (Torsion points are roots).** For $p \neq 2$ and $c \neq 0$, the affine 2-torsion points of $E_c(\mathbb{F}_p)$ are precisely the points $(x, 0)$ with $\psi_2^{(c)}(x) = 0$, and the assignment $(x, 0) \mapsto x$ is a bijection onto the root set. Consequently
$$\#E_c(\mathbb{F}_p)[2] = 1 + \#\{x \in \mathbb{F}_p : x^3 = cx\}.$$

*Proof.* By Lemma 3.2 an affine 2-torsion point has $y = 0$, and then the curve equation reads $0 = x^3 - cx$, i.e. $\psi_2^{(c)}(x) = 0$. Conversely any root $x$ of $\psi_2^{(c)}$ gives a point $(x,0)$ on the curve, which is nonsingular whenever $x$ is a simple root, i.e. whenever $3x^2 - c \neq 0$; for $c \neq 0$ the cubic $X^3 - cX = X(X^2-c)$ is separable (its roots $0, \pm\sqrt c$ are distinct in $\overline{\mathbb{F}_p}$ since $c \neq 0$ and $p \neq 2$), so this holds at every root. The map is injective because the $y$-coordinate is determined. The extra $+1$ counts $\mathcal{O}$. $\square$

**Lemma 3.4 (Root set of the 2-division cubic).** For $c \neq 0$,
$$\{x : x^3 = cx\} = \{0\} \sqcup \mathrm{Sqrt}(c),$$
a disjoint union, so the root count is $1 + \#\mathrm{Sqrt}(c)$.

*Proof.* $x^3 - cx = x(x^2 - c)$, so a root satisfies $x = 0$ or $x^2 = c$. Disjointness: $0 \in \mathrm{Sqrt}(c)$ would give $c = 0$. $\square$

Combining Proposition 3.3, Lemma 3.4 and Lemma 2.4:

**Theorem 3.5 (Local two-regime count).** Let $p \neq 2$ and $c \in \mathbb{F}_p^\times$.
- If $c$ is a square, $\#E_c(\mathbb{F}_p)[2] = 1 + 1 + 2 = 4$.
- If $c$ is not a square, $\#E_c(\mathbb{F}_p)[2] = 1 + 1 + 0 = 2$.

(If $c$ is a non-square then automatically $c \neq 0$, since $0$ is a square.)

### 3.1 Factorisation type

The same computation says exactly how $\psi_2^{(c)}$ factors, and it is worth recording separately because it is the statement that generalises to higher division polynomials.

**Proposition 3.6 (Split factorisation).** If $c = s^2$ with $s \in \mathbb{F}_p$, then in $\mathbb{F}_p[X]$
$$\psi_2^{(c)}(X) = X\,(X - s)\,(X + s),$$
a product of three linear factors, distinct whenever $c \neq 0$.

*Proof.* Expand: $X(X-s)(X+s) = X(X^2 - s^2) = X^3 - s^2 X = X^3 - cX$. $\square$

**Proposition 3.7 (Non-split factorisation).** For any $c$ one has $\psi_2^{(c)}(X) = X\,(X^2 - c)$, and if $c$ is not a square in $\mathbb{F}_p$ then $X^2 - c$ is irreducible over $\mathbb{F}_p$.

*Proof.* The identity is a one-line expansion. For irreducibility: a polynomial of degree $2$ (indeed of degree $\leq 3$) over a field is reducible iff it has a root. If $x$ were a root of $X^2 - c$ then $x^2 = c$, contradicting the non-squareness of $c$. $\square$

Thus the splitting field of $\psi_2^{(c)}$ over $\mathbb{F}_p$ is $\mathbb{F}_p$ itself in the split regime and $\mathbb{F}_{p^2}$ in the non-split regime, matching the two possible orders $4$ and $2$ for the rational 2-torsion.

---

## 4. The group-theoretic upgrade

Theorem 3.5 is a cardinality statement. We now identify the isomorphism type, which is where "Klein four" becomes a theorem rather than a name.

**Theorem 4.1 (Split regime: the 2-torsion is Klein four).** Let $p \neq 2$ and let $c = s^2 \neq 0$ in $\mathbb{F}_p$. Then
$$E_c(\mathbb{F}_p)[2] = \{\mathcal{O},\ (0,0),\ (s,0),\ (-s,0)\}$$
is a group of order four in which every element $g$ satisfies $g + g = \mathcal{O}$; hence it has exponent $2$ and is isomorphic to $\mathbb{Z}/2 \times \mathbb{Z}/2$.

*Proof.* The listed set is exactly the 2-torsion by Proposition 3.3 and Proposition 3.6, and its four elements are distinct: $s \neq 0$ because $c \neq 0$, and $s \neq -s$ because $p \neq 2$. Every element is 2-torsion by definition of the subgroup, so the exponent divides $2$; the group is nontrivial (it contains $(0,0) \neq \mathcal{O}$), so the exponent is exactly $2$. A group of order $4$ and exponent $2$ is an $\mathbb{F}_2$-vector space of dimension $2$, hence $\cong \mathbb{Z}/2 \times \mathbb{Z}/2$. $\square$

**Theorem 4.2 (Non-split regime).** If $p \neq 2$ and $c$ is a non-square, then
$$E_c(\mathbb{F}_p)[2] = \{\mathcal{O}, (0,0)\} \cong \mathbb{Z}/2,$$
and in particular $E_c(\mathbb{F}_p)$ contains no Klein four-subgroup of 2-torsion.

*Proof.* By Proposition 3.3 and Lemma 3.4 the affine 2-torsion consists of the roots of $X(X^2-c)$, and $X^2 - c$ has no roots. The two listed points are distinct. A Klein four-group has order $4 \neq 2$. $\square$

**Corollary 4.3 (Divisibility of the point count).** Let $p \neq 2$ and $c \in \mathbb{F}_p^\times$.
1. $2 \mid \#E_c(\mathbb{F}_p)$, always: the point $(0,0)$ has order exactly two, so $\langle (0,0)\rangle$ is a subgroup of order two, and Lagrange applies.
2. If $c$ is a square, $4 \mid \#E_c(\mathbb{F}_p)$: the Klein four-subgroup of Theorem 4.1 has order four.

*Proof.* $E_c(\mathbb{F}_p)$ is finite (a point is determined by an $(x,y)$ pair together with $\mathcal{O}$), and $\#E_c(\mathbb{F}_p) > 0$, so the divisibility statements are non-vacuous. Both follow from Lagrange's theorem applied to the indicated subgroup. $\square$

Corollary 4.3 has practical bite. The Hasse bound gives $\#E_c(\mathbb{F}_p) = p + 1 - t$ with $|t| \le 2\sqrt p$; part (2) forces $t \equiv p + 1 \pmod 4$, cutting the admissible trace values by a factor of four and guaranteeing a cofactor divisible by $4$ in any cryptographic use of $E_c$ with $c$ a square.

---

## 5. Twist invariance and the summed law

**Lemma 5.1 (Squareness is a twist invariant).** Let $a, d \in \mathbb{F}_p$ with $d \neq 0$. Then $a d^2$ is a square if and only if $a$ is.

*Proof.* If $a = s^2$ then $ad^2 = (sd)^2$. Conversely if $ad^2 = t^2$ then $a = (t/d)^2$, legitimate since $d$ is invertible. $\square$

The content of Lemma 5.1 is that the field extension of $\mathbb{F}_p$ over which the full 2-torsion of $E_{a,d}$ becomes rational — namely $\mathbb{F}_p(\sqrt{a d^2}) = \mathbb{F}_p(\sqrt a)$ — is *independent of $d$*. All members of a quadratic twist family share a single 2-division field. This is the reason the summed count has only two possible values.

**Definition 5.2 (Summed count).** For $a \in \mathbb{F}_p^\times$ set
$$\Sigma_a(p) := \sum_{d \in \mathbb{F}_p^\times} \#E_{a,d}(\mathbb{F}_p)[2], \qquad E_{a,d} : y^2 = x^3 - a d^2 x .$$

**Theorem 5.3 (General two-regime law; Theorem A).** Let $p \neq 2$ and $a \in \mathbb{F}_p^\times$. Then
$$\Sigma_a(p) = \begin{cases} 4(p-1) & \text{if } a \text{ is a square in } \mathbb{F}_p,\\ 2(p-1) & \text{otherwise.}\end{cases}$$

*Proof.* Fix $d \neq 0$ and put $c = a d^2$, which is nonzero since $\mathbb{F}_p$ is a domain. By Lemma 5.1, $c$ is a square iff $a$ is. By Theorem 3.5 the $d$-th summand equals $4$ in the square case and $2$ in the non-square case, in either case independently of $d$. The index set $\mathbb{F}_p^\times$ has $p - 1$ elements, so the sum is a constant times $p-1$. $\square$

### 5.1 The reciprocity input

Theorem 5.3 reduces everything to a single Legendre symbol. We now make it explicit for the three classical parameters.

**Lemma 5.4.** Let $p \neq 3$ be prime. Then $p \not\equiv 0 \pmod 3$, and the image of $p$ in $\mathbb{F}_3$ is a square if and only if $p \equiv 1 \pmod 3$.

*Proof.* The first claim is Lemma 2.2 read the other way. For the second, $p \bmod 3 \in \{1, 2\}$; the squares in $\mathbb{F}_3$ are $\{0, 1\}$, so the image is a square iff $p \equiv 1$. $\square$

**Theorem 5.5 (Reciprocity criterion for $a = 3$).** Let $p \notin \{2,3\}$ be prime. Then $3$ is a square modulo $p$ if and only if $p \equiv 1$ or $p \equiv 11 \pmod{12}$.

*Proof sketch.* $p$ is odd, so $p \equiv 1$ or $3 \pmod 4$. Quadratic reciprocity for the pair $(p, 3)$ in the two forms
- if $p \equiv 1 \pmod 4$: $3$ is a square mod $p$ $\iff$ $p$ is a square mod $3$;
- if $p \equiv 3 \pmod 4$: $3$ is a square mod $p$ $\iff$ $p$ is *not* a square mod $3$ (equivalently, $-p$ is),

combined with Lemma 5.4 ($p$ a square mod $3$ $\iff$ $p \equiv 1 \pmod 3$), gives:
- $p \equiv 1 \pmod 4$ and $p \equiv 1 \pmod 3$, i.e. $p \equiv 1 \pmod{12}$: split;
- $p \equiv 1 \pmod 4$ and $p \equiv 2 \pmod 3$, i.e. $p \equiv 5 \pmod{12}$: non-split;
- $p \equiv 3 \pmod 4$ and $p \equiv 1 \pmod 3$, i.e. $p \equiv 7 \pmod{12}$: non-split;
- $p \equiv 3 \pmod 4$ and $p \equiv 2 \pmod 3$, i.e. $p \equiv 11 \pmod{12}$: split.

The four residues $1, 5, 7, 11$ exhaust the units mod $12$ by the Chinese Remainder Theorem, so the case analysis is complete. $\square$

**Corollary 5.6 (The mod-12 dichotomy; Theorem C for $a=3$).** For $p \notin \{2,3\}$,
$$\Sigma_3(p) = \begin{cases} 4(p-1), & p \equiv 1, 11 \pmod{12},\\[2pt] 2(p-1), & p \equiv 5, 7 \pmod{12}.\end{cases}$$

**Theorem 5.7 (Other reciprocity inputs).** Let $p \neq 2$.
1. *(Second supplementary law.)* $\Sigma_2(p) = 4(p-1)$ if $p \equiv 1$ or $7 \pmod 8$, and $2(p-1)$ otherwise.
2. *(First supplementary law.)* $\Sigma_{-1}(p) = 4(p-1)$ if $p \equiv 1 \pmod 4$, and $2(p-1)$ otherwise. (Here the family is $y^2 = x^3 + d^2 x$.)

*Proof.* Immediate from Theorem 5.3 together with the classical criteria: $2$ is a quadratic residue mod $p$ iff $p \equiv \pm 1 \pmod 8$; $-1$ is a quadratic residue mod $p$ iff $p \equiv 1 \pmod 4$. In each case the parameter is nonzero in $\mathbb{F}_p$ (Lemma 2.2 for $a = 2$; $-1 \neq 0$ trivially). $\square$

The point of Theorem 5.7 is structural: the *geometric* content of the two-regime law is a single sentence (Lemma 5.1 plus Theorem 3.5), and all the arithmetic variety — mod $12$, mod $8$, mod $4$ — comes from the choice of reciprocity law used to evaluate one Legendre symbol.

### 5.2 Numerical values

The table lists $\Sigma_3(p)$ for the small primes, with $\varepsilon = \pm$ indicating split/non-split.

| $p$ | $p \bmod 12$ | regime | $\Sigma_3(p)$ | $= $ |
|---|---|---|---|---|
| $5$ | $5$ | non-split | $8$ | $2 \cdot 4$ |
| $7$ | $7$ | non-split | $12$ | $2 \cdot 6$ |
| $11$ | $11$ | split | $40$ | $4 \cdot 10$ |
| $13$ | $1$ | split | $48$ | $4 \cdot 12$ |
| $17$ | $5$ | non-split | $32$ | $2 \cdot 16$ |
| $19$ | $7$ | non-split | $36$ | $2 \cdot 18$ |
| $23$ | $11$ | split | $88$ | $4 \cdot 22$ |

Note the non-monotonicity: $\Sigma_3(13) = 48 > 32 = \Sigma_3(17)$. The sequence is the product of a smooth factor $p-1$ with a factor of $2$ or $4$ dictated purely by the residue class.

---

## 6. The 3-division polynomial, and the collapse of the arithmetic

We now change families and change primes, moving from $2$-torsion on $y^2 = x^3 - cx$ to $3$-torsion on $y^2 = x^3 + b$.

**Definition 6.1 (3-division polynomial of the $j=0$ family).** For $b \in \mathbb{F}_p$ put
$$\psi_3^{(b)}(X) := 3X^4 + 12 b X \in \mathbb{F}_p[X].$$
Its roots in $\overline{\mathbb{F}_p}$ are the $x$-coordinates of the nonzero 3-torsion points of $C_b : y^2 = x^3 + b$.

**Proposition 6.2 (Factorisation).** $\psi_3^{(b)}(X) = 3X\,(X^3 + 4b)$.

*Proof.* $3X(X^3 + 4b) = 3X^4 + 12 bX$. $\square$

**Proposition 6.3 (Root criterion).** Let $3 \neq 0$ in $\mathbb{F}_p$. Then for $x \in \mathbb{F}_p$,
$$\psi_3^{(b)}(x) = 0 \iff x = 0 \ \text{ or } \ x^3 = -4b .$$

*Proof.* Evaluate: $\psi_3^{(b)}(x) = 3x(x^3 + 4b)$. In a field a product vanishes iff a factor does; the factor $3$ is nonzero by hypothesis. $\square$

**Proposition 6.4 (Local root count).** Let $p \neq 2, 3$ and $b \in \mathbb{F}_p^\times$. Then
$$\#\{x \in \mathbb{F}_p : \psi_3^{(b)}(x) = 0\} = 1 + \#\{x \in \mathbb{F}_p : x^3 = -4b\}.$$

*Proof.* By Proposition 6.3 the root set is $\{0\} \cup \{x : x^3 = -4b\}$, and this union is disjoint: $0^3 = 0 \neq -4b$ because $4 \neq 0$ (Lemma 2.2 and $\mathbb{F}_p$ a domain) and $b \neq 0$. $\square$

### 6.1 Cubing in the two characteristics

**Lemma 6.5 (Cubing is bijective when $p \equiv 2 \bmod 3$).** If $p \equiv 2 \pmod 3$, the map $x \mapsto x^3$ on $\mathbb{F}_p$ is injective, hence bijective.

*Proof.* Choose $k \in \mathbb{N}$ with $3k = 2(p-1) + 1$; such a $k$ exists because $2(p-1) + 1 = 2p - 1 \equiv 2\cdot 2 - 1 = 3 \equiv 0 \pmod 3$. We claim $(x^3)^k = x$ for all $x$. For $x = 0$ this is clear ($k \neq 0$). For $x \neq 0$, Fermat gives $x^{p-1} = 1$, so
$$(x^3)^k = x^{3k} = x^{2(p-1)+1} = (x^{p-1})^2 \cdot x = x .$$
Thus $x \mapsto x^3$ has a left inverse $t \mapsto t^k$ and is injective; a self-map of a finite set that is injective is bijective. $\square$

**Corollary 6.6.** If $p \equiv 2 \pmod 3$ then every $a \in \mathbb{F}_p$ has exactly one cube root, so by Proposition 6.4 every $C_b$ with $b \neq 0$ has exactly $2$ rational $x$-coordinates of 3-torsion.

If instead $p \equiv 1 \pmod 3$, then $\mathbb{F}_p^\times$ is cyclic of order divisible by $3$, so it contains the two primitive cube roots of unity and the cubing map is exactly $3$-to-$1$ on $\mathbb{F}_p^\times$. Then $\#\{x : x^3 = -4b\}$ equals $3$ for the $(p-1)/3$ values of $b$ making $-4b$ a cube, and $0$ for the other $2(p-1)/3$ values. Local counts are therefore $4$ or $1$, wildly non-constant.

### 6.2 The summed count

**Theorem 6.7 (Regime-independent summed count; Theorem D).** Let $p \neq 2, 3$. Then
$$\sum_{b \in \mathbb{F}_p^\times} \#\{x \in \mathbb{F}_p : \psi_3^{(b)}(x) = 0\} = 2(p-1).$$

*Proof.* By Proposition 6.4 the sum equals
$$\sum_{b \neq 0} \Bigl(1 + \#\{x : x^3 = -4b\}\Bigr) = (p-1) + \sum_{b \neq 0} \#\{x \in \mathbb{F}_p : x^3 = -4b\}.$$
It remains to show the second sum equals $p - 1$. Consider the map
$$\varphi : \mathbb{F}_p^\times \to \mathbb{F}_p^\times, \qquad \varphi(x) = -x^3/4 .$$
It is well defined: if $x \neq 0$ then $x^3 \neq 0$ and $4 \neq 0$, so $\varphi(x) \neq 0$. Partitioning the domain $\mathbb{F}_p^\times$ into the fibres of $\varphi$ gives
$$p - 1 = \#\mathbb{F}_p^\times = \sum_{b \in \mathbb{F}_p^\times} \#\varphi^{-1}(b).$$
Finally, for each $b \neq 0$ the fibre $\varphi^{-1}(b) = \{x \neq 0 : -x^3/4 = b\}$ coincides with $\{x \in \mathbb{F}_p : x^3 = -4b\}$: the equation $-x^3/4 = b$ is equivalent to $x^3 = -4b$ after clearing the invertible denominator, and any solution is automatically nonzero because $-4b \neq 0$. Substituting gives $\sum_{b \neq 0}\#\{x : x^3 = -4b\} = p-1$, whence the total $ (p-1) + (p-1) = 2(p-1)$. $\square$

**Remark 6.8 (Why the arithmetic disappears).** The proof never asks how many cube roots any particular element has. It counts the set of *pairs* $\{(b, x) : b \neq 0,\ x^3 = -4b\}$ and observes that projecting to the $x$-coordinate is a bijection onto $\mathbb{F}_p^\times$ — the value of $b$ is *determined* by $x$. Projecting to $b$ instead is the erratic direction, and it is only in that direction that the cubic residue character of $-4b$, and hence $p \bmod 3$, is visible. The summation, by fibering the other way, is blind to it.

**Example 6.9.** At $p = 7 \equiv 1 \pmod 3$ the individual counts over $b = 1, \dots, 6$ are $\{1, 4, 1, 1, 4, 1\}$, summing to $12 = 2 \cdot 6$. At $p = 11 \equiv 2 \pmod 3$ every individual count is $2$, and the sum is $20 = 2 \cdot 10$. Two entirely different local pictures, the same global answer.

---

## 7. Algorithms

The results above are effective, and the algorithms extracted from them are of independent interest because they replace an $O(p)$ enumeration by an $O(\log p)$ character evaluation.

### 7.1 Regime classification

**Algorithm 1 (Regime of a twist family).**
*Input:* an odd prime $p$, a parameter $a$ with $p \nmid a$.
*Output:* $\Sigma_a(p)$, together with the isomorphism type of the common 2-torsion group.

1. Compute the Legendre symbol $\chi = \left(\tfrac{a}{p}\right)$ by Euler's criterion $a^{(p-1)/2} \bmod p$, or faster by the binary reciprocity algorithm.
2. If $\chi = +1$, return $\bigl(4(p-1),\ \mathbb{Z}/2 \times \mathbb{Z}/2\bigr)$.
3. Otherwise return $\bigl(2(p-1),\ \mathbb{Z}/2\bigr)$.

Complexity: $O(\log^2 p)$ bit operations using the reciprocity-based Jacobi-symbol algorithm, versus $\Theta(p \log p)$ for naive enumeration of the family. Correctness is Theorem 5.3 with Theorems 4.1 and 4.2.

For $a \in \{3, 2, -1\}$ step 1 can be replaced by a single residue test — $p \bmod 12 \in \{1,11\}$, $p \bmod 8 \in \{1,7\}$, $p \bmod 4 = 1$ respectively — by Theorems 5.5 and 5.7, reducing the cost to a single division.

### 7.2 Explicit torsion points

**Algorithm 2 (Klein four generators).**
*Input:* an odd prime $p$ and $c \in \mathbb{F}_p^\times$ a quadratic residue.
*Output:* the four elements of $E_c(\mathbb{F}_p)[2]$.

1. Compute a square root $s$ of $c$ modulo $p$: if $p \equiv 3 \pmod 4$ take $s = c^{(p+1)/4}$; otherwise run Tonelli–Shanks.
2. Return $\{\mathcal{O}, (0,0), (s,0), (-s,0)\}$.

Correctness is Theorem 4.1. Complexity is $O(\log^3 p)$ in the worst case (Tonelli–Shanks), $O(\log^3 p)$ deterministic when $p \equiv 3 \pmod 4$.

### 7.3 Summed 3-division count

**Algorithm 3 (Verification of the collapse).**
*Input:* a prime $p \neq 2, 3$.
*Output:* the pair (list of local counts $\#\{x : \psi_3^{(b)}(x)=0\}$ for $b \in \mathbb{F}_p^\times$, their sum).

1. Build the cube table $T[x] = x^3 \bmod p$ for $x = 0, \dots, p-1$.
2. For each $b \in \{1, \dots, p-1\}$, count $m_b = \#\{x : T[x] = (-4b) \bmod p\}$ and record $1 + m_b$.
3. Return the list and its total, which is $2(p-1)$ by Theorem 6.7.

Complexity $O(p)$ with $O(p)$ memory (or $O(p)$ time and $O(1)$ extra memory via a bucket pass). The output list is constant $= 2$ when $p \equiv 2 \pmod 3$ and takes only the values $1$ and $4$ when $p \equiv 1 \pmod 3$, with exactly $(p-1)/3$ entries equal to $4$.

---

## 8. Discussion and future directions

### 8.1 What was actually used

It is worth isolating the logical skeleton, because it explains why the theorems are unconditional and why they are sharp.

- *Geometry:* on $y^2 = f(x)$ in odd characteristic, 2-torsion $=$ roots of $f$ $+$ one point at infinity. (Lemma 3.2.)
- *Algebra:* $X^3 - cX = X(X^2-c)$; a quadratic over a field is irreducible iff rootless. (Propositions 3.6, 3.7.)
- *Invariance:* squareness is unchanged by multiplication by a nonzero square. (Lemma 5.1.)
- *Arithmetic:* one Legendre symbol, evaluated by reciprocity. (Theorems 5.5, 5.7.)

Only the last item is deep, and it is entirely classical. The first three are the reason the statement holds *unconditionally in both regimes* with no exceptional primes beyond $p \in \{2,3\}$ — which are excluded because $2 = 0$ destroys Lemma 3.2 and $3 = 0$ destroys the reciprocity input for $a=3$ (respectively the factor $3$ in $\psi_3$).

### 8.2 Sharpness

Theorem 5.3 is sharp in the sense that both values $4(p-1)$ and $2(p-1)$ occur for infinitely many $p$: by Dirichlet's theorem each of the four classes $1, 5, 7, 11 \bmod 12$ contains infinitely many primes, with natural density $1/4$ within the primes. Hence $\Sigma_3(p) = 4(p-1)$ for a set of primes of density $1/2$.

### 8.3 Future directions

**Direction 1 — Higher division-polynomial fibre dichotomy.** For $n \ge 4$ the $n$-division polynomial $\psi_n$ of the twist family factors over the $n$-division field $\mathbb{Q}(E[n])$ rather than over a single quadratic field, and the summed fibre count should be governed by the splitting type of $p$ in $\mathbb{Q}(E[n])$ — a non-abelian invariant for generic $E$.

> **Conjecture.** For the family $E_{a,d} : y^2 = x^3 - a d^2 x$ and each $n$, the sum $\sum_{d \neq 0} \#\{x : \psi_n^{(d)}(x) = 0\}$ is a function of the Frobenius conjugacy class of $p$ in $\mathrm{Gal}(\mathbb{Q}(E[n])/\mathbb{Q})$ alone, and equals $(p-1)\,c_n(\mathrm{Frob}_p)$ for an explicit integer $c_n$.

The key insight is that the twisting parameter $d$ acts on the fibres by a scaling that is a bijection of $\mathbb{F}_p^\times$, so the summed count only sees the *isomorphism class of the splitting field*, not the individual twist — precisely the mechanism isolated above for $n = 2$ and $n = 3$. The $n=2$ case is settled completely (Corollary 5.6) and the $n=3$ case exhibits the regime-independence phenomenon (Theorem 6.7), so the shape of the general statement can be tested against two proven anchors.

**Direction 2 — Klein-four density in twist families.**

> **Conjecture.** For fixed squarefree $a$, the density of primes $p$ for which $E_a(\mathbb{F}_p)[2] \cong \mathbb{Z}/2 \times \mathbb{Z}/2$ is exactly $1/2$, and the discrepancy $\#\{p \le X : \text{split}\} - \pi(X)/2$ is $O(X^{1/2 + \varepsilon})$ under the Generalized Riemann Hypothesis.

The key insight is that the split condition proved here is *exactly* a quadratic-character condition on $a$, so the density statement reduces to Chebotarev/Dirichlet for the single quadratic field $\mathbb{Q}(\sqrt a)$, with the error term controlled by the associated Dirichlet $L$-function. Theorem 5.3 reduces the geometric condition to the squareness of $a$ unconditionally, so the analytic input needed is now completely isolated from the elliptic-curve geometry.

**Direction 3 — Exponent-two subgroup classification.** More generally one can ask, for a fixed finite abelian group $G$ of exponent two, for which $p$ and which members of a given family $G$ embeds into $E(\mathbb{F}_p)$. For elliptic curves the answer is bounded ($E[2] \cong (\mathbb{Z}/2)^r$ with $r \le 2$), so the classification here is complete for $n = 2$; the interesting version of the question is for abelian surfaces and higher-dimensional Jacobians, where the full 2-torsion has rank up to $2g$ and the splitting behaviour of the corresponding degree-$(2g+1)$ or $(2g+2)$ hyperelliptic model over $\mathbb{F}_p$ replaces the single Legendre symbol by a cycle-type statistic in $S_{2g+2}$.

**Direction 4 — Effective ranges and record searches.** The two-regime law makes it trivial to generate, for any target $N$, a curve in the family whose point count is divisible by $4$ (choose $p \equiv \pm 1 \bmod 12$) or guaranteed *not* divisible by $4$ from the 2-torsion (choose $p \equiv 5, 7 \bmod 12$). Whether the resulting families have unusual distributions of the cofactor $\#E(\mathbb{F}_p)/4$ — and in particular how often that cofactor is prime — is an accessible experimental question with immediate relevance to curve selection.

### 8.4 Concluding remarks

The mathematics in this paper is elementary in its ingredients and, we would argue, non-obvious in its organisation. The two theorems that sit side by side — a summed count that *is* arithmetic (Theorem 5.3, with the mod-12 refinement of Corollary 5.6) and a summed count that *is not* (Theorem 6.7) — form a matched pair that isolates a general principle: the arithmetic content of a family-summed invariant is exactly what the family action fails to average away. In the 2-torsion case the family acts by scaling the coefficient by squares, and the quadratic character is an invariant of that action, so it survives. In the 3-division case the family acts by sweeping the cube-translate through every nonzero value once, and nothing survives.

Both are instances of the same computation done with the same tools; only the group action differs. Recognising that difference is the whole content of knowing when a congruence condition on $p$ should be expected to appear in an answer, and when it should be expected to cancel.
