# Euler's Two-Squares Route, Fully Priced: Unconditional Extraction, an Exact Eligibility Class, and a Quartic Search Barrier

**Author:** Aristotle
**Date:** 2026-08-30

---

## Abstract

Euler's factorisation method converts two essentially distinct representations of an integer $N$ as a sum of two squares, $N = a^2 + b^2 = c^2 + d^2$, into a nontrivial divisor by a single greatest-common-divisor computation. We give a complete accounting of the method: its algebraic core, its exact domain of applicability, and an unconditional lower bound on the cost of its input.

Three results form the backbone.

*Extraction.* We prove that $1 < \gcd(ad-bc,\,N) < N$ whenever the two representations are essentially distinct, with **no** primality, smoothness, genericity or distributional hypothesis, and with the parts allowed to lie on the closed cone $a,b,c,d \geq 0$. The proof combines the two Brahmagupta–Fibonacci identities with a rigidity lemma that is the integral equality case of Cauchy–Schwarz. As corollaries we obtain the essential uniqueness of the two-squares representation of a prime, the identity $\gcd(ad-bc,N)\cdot\gcd(ad+bc,N) = pq$ for semiprimes, and — on the canonical Brahmagupta pair — the *exact* identities $AD - BC = 2efq$ and $AD+BC = 2ghp$, which pin the two extracted divisors to $q$ and $p$ respectively.

*Eligibility.* For $N = pq$ with $p \neq q$ odd primes, two essentially distinct representations exist **iff** $p \equiv q \equiv 1 \pmod 4$, and in that case there are exactly two. The upper bound is proved by an injective class map into $\{0,1\}^2$, whose two coordinates we identify with divisibility by the conjugate Gaussian primes above $p$ and above $q$. Consequently the eligible fraction of pairs of odd primes is exactly $1/4$ in the limit.

*Cost.* We prove an unconditional **quartic barrier**: if a search bound $t$ has reached the smaller part of each of two essentially distinct representations of $N$, then $2N < t^4$. A gap-refined form gives $2k^2N < c^4$ when the large parts differ by $k$, whence three representations force $8N < a_3^4$. Combined with the exact criterion for Fermat's difference-of-squares scan to halt on its first trial — namely $(q-p)^2 < 4(p+q)$ — this yields: on a balanced eligible semiprime, Fermat succeeds in one step while any representation search that collects both representations must run past $(2N)^{1/4}$, twice. The measured constant-factor loss of the representation route is therefore forced, not an artefact of sampling.

**Keywords:** sum of two squares, Euler factorisation, Brahmagupta–Fibonacci identity, Gaussian integers, Fermat's difference of squares, integer factorisation, search lower bound.

---

## 1. Introduction

### 1.1 The method

Euler observed that a number possessing two genuinely different decompositions into a sum of two squares reveals its factorisation immediately. The recipe is one line: from
$$N = a^2 + b^2 = c^2 + d^2$$
compute $\gcd(ad - bc,\, N)$.

For $N = 221$ we have $221 = 5^2 + 14^2 = 10^2 + 11^2$, so $ad - bc = 5\cdot 11 - 14 \cdot 10 = -85$ and $\gcd(85, 221) = 17$; the complementary cross-term $ad + bc = 195$ gives $\gcd(195,221) = 13$, and $221 = 13\cdot 17$.

Conceptually the cross-term is an imaginary part. Identify a representation with a Gaussian integer $z_1 = a + bi$ of norm $N$, and the second with $z_2 = c+di$. Then
$$z_1 \overline{z_2} = (ac+bd) + (ad - bc)\,i,$$
so $ad - bc = \operatorname{Im}(z_1\overline{z_2})$ and $ac+bd = \operatorname{Re}(z_1 \overline{z_2})$, and $|z_1\overline{z_2}| = N$. The method is a statement about two lattice points on the circle of radius $\sqrt N$.

### 1.2 What is at stake, and what we prove

Any honest evaluation of a factorisation method has three faces:

- **Eligibility.** On what fraction of inputs is the method even defined?
- **Correctness.** When defined, does the extraction succeed — always, or only usually?
- **Cost.** What does it cost to produce the method's input, compared with a competitor doing the same job?

The literature treats the first two informally and the third anecdotally. This paper settles all three unconditionally.

Section 3 proves the extraction theorem in maximal generality. Section 4 determines the eligibility class exactly and identifies the underlying combinatorics with Gaussian splitting. Section 5 makes the extracted divisor deterministic. Section 6 analyses the competing Fermat scan exactly. Section 7 proves the quartic search barrier and assembles the comparison. Section 8 reports the numerical picture, Section 9 discusses, and Section 10 lists open directions.

### 1.3 Conventions

All variables denote integers unless stated. A **representation** of $N$ is a pair $(a,b)$ of integers with $a^2+b^2 = N$; it is *positive* if $a,b > 0$ and *normalised* if $0 < a \le b$. Two representations $(a,b)$ and $(c,d)$ are **essentially distinct** if
$$\lnot(c = a \wedge d = b) \quad\text{and}\quad \lnot(d = a \wedge c = b),$$
i.e. they differ as unordered pairs. We write $r_2(n)$ for the number of ordered integer pairs $(x,y)$, signs and zeros included, with $x^2+y^2 = n$.

---

## 2. The two Brahmagupta–Fibonacci identities

Everything in Section 3 flows from two polynomial identities, valid over any commutative ring.

**Lemma 2.1 (Brahmagupta–Fibonacci, subtractive branch).**
$$(a^2+b^2)(c^2+d^2) = (ac+bd)^2 + (ad-bc)^2.$$

**Lemma 2.2 (Brahmagupta–Fibonacci, additive branch).**
$$(a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2.$$

Both are verified by expansion; they are the real and imaginary parts of the multiplicativity of the Gaussian norm applied to $z_1\overline{z_2}$ and $z_1 z_2$ respectively.

The engine of the method is the divisibility they generate when the two norms coincide.

**Lemma 2.3 (Cross-product divisibility).** *If $c^2+d^2 = a^2+b^2$ then*
$$(a^2+b^2) \mid (ad-bc)(ad+bc).$$

*Proof.* $(ad-bc)(ad+bc) = a^2d^2 - b^2c^2 = a^2(c^2+d^2) - c^2(a^2+b^2) = (a^2 - c^2)(a^2+b^2)$, using $c^2+d^2 = a^2+b^2$ in the middle step. $\square$

So $N = a^2+b^2$ divides the product of the two cross-terms. If $N$ divided neither of them properly it would have to divide one of them entirely, or be coprime to one — and Section 3 shows both are impossible.

---

## 3. Unconditional extraction

### 3.1 Rigidity

**Lemma 3.1 (Rigidity; integral equality case of Cauchy–Schwarz).** *Let $a,b,c,d \in \mathbb{Z}$ with $a^2+b^2 > 0$. If*
$$ad = bc \qquad\text{and}\qquad ac+bd = a^2+b^2,$$
*then $c = a$ and $d = b$.*

*Proof.* The linear combination $a(ac+bd) - b(ad-bc) = c(a^2+b^2)$ is an identity. Substituting the two hypotheses gives $a(a^2+b^2) = c(a^2+b^2)$, and since $a^2+b^2 \neq 0$ we may cancel to get $c = a$. For the second coordinate: if $b \neq 0$, substituting $c=a$ into $ac+bd = a^2+b^2$ gives $bd = b^2$, hence $d=b$. If $b = 0$ then $a \neq 0$, and $ad = bc = 0$ forces $d = 0 = b$. $\square$

Geometrically: $ad-bc = 0$ says $(a,b) \parallel (c,d)$, while $ac+bd = |(a,b)|^2$ says the projection of $(c,d)$ onto $(a,b)$ is exactly $(a,b)$. Parallel plus correctly-scaled gives equality. Nothing is assumed about $c^2+d^2$.

### 3.2 The two failure modes

**Proposition 3.2 (The cross-term is not a multiple of $N$).** *Let $a,b,c,d > 0$ with $c^2+d^2 = a^2+b^2 =: N$, and suppose $(c,d) \neq (a,b)$. Then $N \nmid (ad-bc)$.*

*Proof.* By Lemma 2.1 with $c^2+d^2=a^2+b^2$,
$$(ac+bd)^2 + (ad-bc)^2 = N^2. \tag{3.1}$$
Suppose $ad-bc = Nk$. Then $(ac+bd)^2 = N^2(1-k^2)$. Since $a,b,c,d>0$ we have $ac+bd>0$, so $1-k^2 > 0$, forcing $k=0$. Hence $ad = bc$ and $(ac+bd)^2 = N^2$ with $ac+bd>0$, so $ac+bd = N = a^2+b^2$. Lemma 3.1 gives $(c,d)=(a,b)$, a contradiction. $\square$

**Proposition 3.3 (The conjugate cross-term is not a multiple of $N$).** *Under the same positivity and norm hypotheses, if $(d,c) \neq (a,b)$ then $N \nmid (ad+bc)$.*

*Proof.* By Lemma 2.2, $(ac-bd)^2 + (ad+bc)^2 = N^2$, so $ad+bc \le N$; positivity gives $ad+bc>0$, so a divisibility $N \mid ad+bc$ forces $ad+bc = N$ and then $ac - bd = 0$. Applying Lemma 3.1 with the roles $ad = bc$ replaced by $ac=bd$ (i.e. after swapping $c \leftrightarrow d$) yields $(d,c) = (a,b)$, a contradiction. $\square$

**Corollary 3.4 (The cross-term is not coprime to $N$).** *Under the same hypotheses, if $(d,c) \neq (a,b)$ then $\gcd(ad-bc, N) > 1$.*

*Proof.* If $ad-bc$ were coprime to $N$, Lemma 2.3 would give $N \mid (ad+bc)$, contradicting Proposition 3.3. $\square$

### 3.3 The extraction theorem

**Theorem 3.5 (Euler's Extraction Theorem).** *Let $a,b,c,d$ be positive integers with*
$$a^2 + b^2 = c^2 + d^2 = N,$$
*and suppose the two representations are essentially distinct. Then*
$$1 < \gcd(ad-bc,\, N) < N.$$
*In particular Euler's combination step always returns a proper nontrivial divisor of $N$ — with no primality, smoothness, genericity or distributional hypothesis.*

*Proof.* Write $g = \gcd(ad-bc, N)$. Then $g \mid N$ and $g \mid ad-bc$. If $g = 0$ then $N=0$, excluded. If $g = 1$ then $ad-bc$ is coprime to $N$, contradicting Corollary 3.4 via the second distinctness hypothesis. So $g > 1$. If $g = N$ then $N \mid ad-bc$, contradicting Proposition 3.2 via the first distinctness hypothesis. Hence $g < N$. $\square$

The same argument run on the additive branch gives the companion statement $1 < \gcd(ad+bc,N) < N$.

**Theorem 3.6 (Extraction on the closed cone).** *Theorem 3.5 remains true with the hypotheses weakened to $a,b,c,d \geq 0$ and $N = a^2+b^2 > 0$.*

*Proof sketch.* Only two steps used strict positivity: $ac+bd>0$ in Proposition 3.2 and $ad+bc>0$ in Proposition 3.3. Both survive on the boundary. Suppose $ac+bd = 0$ with all parts $\geq 0$; then $ac = bd = 0$, so the two vectors are supported on complementary coordinates. Case analysis: $a = d = 0$ forces $c^2 = b^2$, i.e. $(d,c) = (a,b)$ — excluded by the second distinctness hypothesis; $c = b = 0$ forces $d^2 = a^2$, likewise excluded; $a = b = 0$ contradicts $N>0$; $c = d = 0$ contradicts $N>0$. The argument for $ad+bc$ is the mirror image, using the first distinctness hypothesis. $\square$

Thus the degenerate representation $25 = 5^2+0^2 = 3^2+4^2$ is covered: $\gcd(5\cdot 4 - 0 \cdot 3, 25) = 5$.

### 3.4 Immediate corollaries

**Corollary 3.7 (Uniqueness for primes).** *A prime $p$ has at most one representation as a sum of two positive squares, up to order.*

*Proof.* Two essentially distinct representations would, by Theorem 3.5, produce a divisor $g$ of $p$ with $1 < g < p$. $\square$

**Corollary 3.8 (Semiprime extraction).** *If $N = pq$ with $p,q$ prime and $a^2+b^2 = c^2+d^2 = N$ are essentially distinct positive representations, then $\gcd(ad-bc,N) \in \{p, q\}$.*

*Proof.* The gcd is a divisor of $pq$ strictly between $1$ and $pq$; the only such divisors are $p$ and $q$. $\square$

**Theorem 3.9 (Both gcds recover the whole factorisation).** *If in addition $p \neq q$, then*
$$\gcd(ad-bc,\, N)\cdot \gcd(ad+bc,\, N) = pq.$$

*Proof.* Both gcds lie in $\{p,q\}$ by Corollary 3.8 and its additive analogue. It remains to exclude that both equal the same prime. By Lemma 2.3, $N \mid (ad-bc)(ad+bc)$; hence for each prime $r \in \{p,q\}$, $r$ divides one of the two cross-terms, and therefore $r$ divides one of the two gcds. If both gcds were $p$, then $q$ would divide $p$; contradiction. Symmetrically for $q$. $\square$

---

## 4. The eligibility class

### 4.1 The negative half

**Theorem 4.1 (Obstruction at $3 \bmod 4$).** *Let $r$ be a prime with $r \equiv 3 \pmod 4$, and let $n$ be a positive integer with $r \mid n$ and $r^2 \nmid n$. Then $n$ is not a sum of two integer squares.*

*Proof sketch.* Suppose $a^2 + b^2 = n$. Reducing mod $r$ gives $a^2 \equiv -b^2$. If $r \nmid b$ then $(ab^{-1})^2 \equiv -1 \pmod r$, so $-1$ is a quadratic residue mod $r$ — impossible for $r \equiv 3 \pmod 4$, since $(-1)^{(r-1)/2} = -1$. Hence $r \mid b$, and then $r \mid a$, so $r^2 \mid a^2+b^2 = n$, contradicting $r^2 \nmid n$. $\square$

For semiprimes $N = pq$ with $p \neq q$ odd, Theorem 4.1 annihilates the cells $(p,q) \equiv (1,3), (3,1), (3,3) \pmod 4$: those $N$ have *no* representations at all, hence certainly no pair of them.

### 4.2 The class map

Fix distinct primes $p \equiv q \equiv 1 \pmod 4$ and representations $p = e^2+f^2$, $q = g^2+h^2$ with $e,f,g,h > 0$ (existence is Fermat's two-squares theorem; $e \neq f$ and $g \neq h$ since $p,q$ are odd).

**Lemma 4.2 (The bit is defined).** *Let $a^2 + b^2 = pq$. Then $p$ divides exactly one of $af - be$ and $af + be$.*

*Proof.* For existence: $(af-be)(af+be) = a^2f^2 - b^2e^2 = f^2(a^2+b^2) - b^2(e^2+f^2) = f^2 pq - b^2 p$, a multiple of $p$; since $p$ is prime it divides one factor. For exclusivity: if it divided both then it would divide their sum $2af$ and their difference $2be$; as $p$ is odd and divides neither $e$ nor $f$ (else $p^2 \mid e^2+f^2 = p$), it would follow that $p \mid a$ and $p \mid b$, whence $p^2 \mid pq$, i.e. $p \mid q$ — contradicting $p \neq q$. $\square$

Define the **class map**
$$\chi(a,b) \;=\; \bigl(\,[\,p \mid af-be\,],\ [\,q \mid ah-bg\,]\,\bigr) \in \{0,1\}^2 .$$

**Lemma 4.3 (Injectivity).** *If two positive representations $(a_1,b_1)$, $(a_2,b_2)$ of $pq$ satisfy $\chi(a_1,b_1) = \chi(a_2,b_2)$, then $(a_1,b_1) = (a_2,b_2)$.*

*Proof sketch.* Equality of the first coordinate forces $p \mid a_1b_2 - a_2b_1$: writing both congruences relative to the same $(e,f)$ and eliminating, the cross-term $a_1b_2 - a_2b_1$ inherits the common divisibility. Similarly $q \mid a_1b_2 - a_2b_1$, so $pq = N$ divides it. But Proposition 3.2 says $N$ can divide the cross-term of two positive representations only if they are literally equal. $\square$

**Theorem 4.4 (Exactly two representations).** *Let $p \neq q$ be primes with $p \equiv q \equiv 1 \pmod 4$. Then $pq$ has exactly two essentially distinct representations as a sum of two positive squares. Explicitly, with $p = e^2+f^2$ and $q = g^2+h^2$, they are*
$$A = eg+fh,\quad B = |eh-fg| \qquad\text{and}\qquad C = |eg-fh|,\quad D = eh+fg,$$
*and the four ordered positive representations are exactly $(A,B), (B,A), (C,D), (D,C)$.*

*Proof.* Lemmas 2.1–2.2 give $A^2+B^2 = C^2+D^2 = pq$; positivity of all four parts and essential distinctness of the two pairs follow from $e\ne f$, $g\ne h$ and $p \neq q$ (in particular $pq$ is not a perfect square, so no part vanishes and no representation is symmetric). This gives at least four ordered representations. Conversely $\chi$ is injective into a four-element set by Lemma 4.3, so there are at most four. $\square$

**Theorem 4.5 (The dichotomy).** *Let $p \neq q$ be odd primes. Then $pq$ admits two essentially distinct representations as a sum of two positive squares if and only if $p \equiv q \equiv 1 \pmod 4$.*

*Proof.* ($\Leftarrow$) Theorem 4.4. ($\Rightarrow$) If say $q \equiv 3 \pmod 4$ then $q \mid pq$ and $q^2 \nmid pq$, so Theorem 4.1 gives no representations at all. $\square$

**Corollary 4.6 (Eligible density).** *Primes $\equiv 1$ and $\equiv 3 \bmod 4$ have equal Dirichlet density $1/2$ among odd primes. Hence for two independently drawn odd primes the probability that $pq$ is eligible for Euler's method is exactly $1/4$, and conditional on eligibility the representation count is exactly $2$.*

### 4.3 The class bit is a Gaussian divisibility

The $\{0,1\}^2$ of Lemma 4.2 looks like bookkeeping. It is not: it is a pair of splitting choices in $\mathbb{Z}[i]$.

**Theorem 4.7 (Bridge to the Gaussian integers).** *Let $p$ be prime with $p = e^2+f^2$, and let $a^2+b^2 = pq$. Then*
$$(e+fi) \mid (a+bi) \ \text{ in }\ \mathbb{Z}[i] \iff p \mid af - be.$$

*Proof.* ($\Rightarrow$) If $a+bi = (e+fi)(u+vi)$ then $a = eu - fv$, $b = ev+fu$, so $af - be = (eu-fv)f - (ev+fu)e = -v(e^2+f^2) = -vp$.
($\Leftarrow$) Suppose $af - be = pv'$. One first shows $p \mid ae+bf$: from the identity
$$(ae+bf)^2 + (af-be)^2 = (a^2+b^2)(e^2+f^2) = p^2 q,$$
we get $(ae+bf)^2 = p^2(q - v'^2)$, so $p^2 \mid (ae+bf)^2$ and hence $p \mid ae+bf$, say $ae+bf = pu$. Then
$$p\,a = a(e^2+f^2) = e(ae+bf) + f(af-be) = p(eu + fv'),$$
$$p\,b = b(e^2+f^2) = f(ae+bf) - e(af-be) = p(fu - ev'),$$
so $a + bi = (e+fi)(u - v'i)$. $\square$

The conjugate statement $(e-fi) \mid (a+bi) \iff p \mid af+be$ follows by replacing $f$ with $-f$.

**Corollary 4.8 (Frobenius dichotomy).** *For distinct primes $p \equiv 1 \pmod 4$ and $q$, and any representation $a^2+b^2 = pq$: exactly one of the two conjugate Gaussian primes $e \pm fi$ above $p$ divides $a+bi$.*

*Proof.* Combine Theorem 4.7 and its conjugate with Lemma 4.2. $\square$

**Corollary 4.9 (Gaussian splitting).** *If $p \mid af-be$ then there is $w \in \mathbb{Z}[i]$ with $a+bi = (e+fi)\,w$ and $\mathrm{N}(w) = q$.*

*Proof.* Existence of $w$ is Theorem 4.7; multiplicativity of the norm gives $pq = p\cdot \mathrm{N}(w)$, so $\mathrm{N}(w) = q$. $\square$

So the elementary two-bit argument of Theorem 4.4 is, structurally, a pair of independent choices of Gaussian prime above $p$ and above $q$ — which is precisely why the representation count is a power of two.

### 4.4 Cross-check: the classical counting function

The count is consistent with the classical formula
$$r_2(n) = 4\,\bigl(d_1(n) - d_3(n)\bigr),$$
where $d_j(n)$ is the number of divisors of $n$ congruent to $j$ modulo $4$. For an eligible semiprime $N = pq$ all four divisors $1, p, q, pq$ are $\equiv 1 \bmod 4$, so $r_2 = 16$; each unordered representation $\{a,b\}$ with $a \neq b$, both positive, accounts for $8$ signed-and-ordered solutions, giving $16/8 = 2$ representations — matching Theorem 4.4 exactly. For $N = 221$: $r_2(221) = 16$ and the representations are $\{5,14\}$ and $\{10,11\}$.

---

## 5. Determinism: which prime comes out

Theorem 3.9 says the two gcds are $p$ and $q$ in some order. On the canonical pair the order is determined, by exact identities.

Keep $p = e^2+f^2$, $q = g^2+h^2$, and set
$$A = eg+fh,\quad B = eh-fg,\quad C = eg-fh,\quad D = eh+fg.$$

**Lemma 5.1 (Exact factorisation of the cross-terms).**
$$AD - BC = 2efq, \qquad AD + BC = 2ghp .$$

*Proof.* Both are polynomial identities after substituting $q = g^2+h^2$ resp. $p = e^2+f^2$:
$$AD - BC = (eg+fh)(eh+fg) - (eh-fg)(eg-fh) = 2ef(g^2+h^2),$$
$$AD + BC = (eg+fh)(eh+fg) + (eh-fg)(eg-fh) = 2gh(e^2+f^2).$$
Expand and compare. $\square$

**Theorem 5.2 (Deterministic extraction).** *Let $p, q$ be odd primes with $p = e^2+f^2$, $q = g^2+h^2$, and $N = pq$. Then*
$$\gcd(AD-BC,\, N) = q, \qquad \gcd(AD+BC,\, N) = p .$$

*Proof.* By Lemma 5.1, $AD-BC = 2efq$, so $q \mid \gcd(AD-BC,N)$ and the gcd is $q$ or $pq$. It is not $pq$: that would need $p \mid 2ef$, and $p$ is odd and divides neither $e$ nor $f$ (if $p \mid e$ and $p \mid f$ then $p^2 \mid e^2+f^2 = p$; and if $p$ divided just one of them, say $p \mid e$, then $p \mid f^2$ hence $p \mid f$). Symmetrically for the additive branch, using that $q$ is odd and divides neither $g$ nor $h$. $\square$

So the subtractive cross-term always returns the prime whose representation was *not* consumed by the twist. Working with normalised non-negative parts one has $|B|\,|C| = |BC|$, and the two branches merge into a single formula whose output is governed purely by the sign of
$$BC = (eh-fg)(eg-fh):$$
when $BC > 0$ the normalised subtractive step yields $q$, when $BC < 0$ it yields $p$, and in either case the result is one of the two primes. This is the sharpest available form of "extraction always works": not merely a proper divisor, but a named one.

**Lemma 5.3 (The twisted parts are never both small).** *With $e,f,g,h>0$, $e \neq f$, $g \neq h$,*
$$B^2 + C^2 \;=\; pq - 4efgh \;\geq\; p + q - 1 .$$

*Proof.* The identity $B^2+C^2 = (e^2+f^2)(g^2+h^2) - 4efgh$ is polynomial. For the bound, $(e-f)^2 \geq 1$ gives $4ef \le 2p-2$ and likewise $4gh \le 2q-2$; multiplying (both sides non-negative) and substituting gives $pq - 4efgh \ge pq - \frac{(2p-2)(2q-2)}{4} = p+q-1$. $\square$

Hence $\max(|B|,|C|) \geq \sqrt{(p+q-1)/2}$: the second representation always sits far from the coordinate axes. This is the arithmetic shadow of the geometric barrier proved next.

---

## 6. The competitor: Fermat's difference-of-squares scan

Fermat's method tries $s = \lceil \sqrt N\rceil, \lceil\sqrt N\rceil + 1, \dots$ until $s^2 - N$ is a perfect square; then $N = (s-t)(s+t)$ with $t^2 = s^2 - N$.

Introduce midpoint/half-gap coordinates: for $N = pq$ with $p < q$ both odd, write
$$p + q = 2u, \qquad q = p + 2v \quad (v>0).$$

**Lemma 6.1 (Correctness and termination point).** $u^2 = pq + v^2$. *Hence the scan terminates exactly at $s = u$.*

*Proof.* $u = p+v$, so $u^2 = p^2 + 2pv + v^2 = p(p+2v) + v^2 = pq + v^2$. $\square$

**Lemma 6.2 (Exact integer-square-root criterion).** *If $N + t^2 = (w+1)^2$ with $t>0$, then $\lfloor \sqrt N\rfloor = w \iff t^2 < 2(w+1)$.*

*Proof.* From $N = (w+1)^2 - t^2 < (w+1)^2$ we always have $\lfloor\sqrt N\rfloor \le w$. And $\lfloor\sqrt N\rfloor \ge w \iff w^2 \le N = (w+1)^2 - t^2 \iff t^2 \le 2w+1 \iff t^2 < 2(w+1)$. $\square$

**Theorem 6.3 (Fermat halts on the first trial iff balanced).** *With $p+q=2u$, $q = p+2v$, $v>0$:*
$$\lfloor\sqrt{pq}\rfloor + 1 = u \iff v^2 < 2u \iff (q-p)^2 < 4(p+q).$$

*Proof.* Apply Lemma 6.2 with $N = pq$, $t = v$, $w+1 = u$, legitimate by Lemma 6.1. $\square$

**Theorem 6.4 (Two-sided scan-length bound).** *For real $p, q > 0$,*
$$\frac{(q-p)^2}{8\max(p,q)} \;\le\; \frac{p+q}{2} - \sqrt{pq} \;\le\; \frac{(q-p)^2}{8\sqrt{pq}} .$$

*Proof.* Put $x = \sqrt p$, $y = \sqrt q$. The middle term is $\tfrac12(x-y)^2$, and $(q-p)^2 = (y-x)^2(x+y)^2$. The upper bound is then $\tfrac12(x-y)^2 \le \frac{(x-y)^2(x+y)^2}{8xy}$, i.e. $4xy \le (x+y)^2$, which is $(x-y)^2 \ge 0$. The lower bound is $\frac{(x-y)^2(x+y)^2}{8\max(x^2,y^2)} \le \tfrac12 (x-y)^2$, i.e. $(x+y)^2 \le 4\max(x^2,y^2)$, which holds since both $x^2,y^2 \le \max$. $\square$

So the scan length is $\Theta\!\left((q-p)^2/\sqrt N\right)$: quadratically small in the imbalance, and free at the balance point.

---

## 7. The quartic barrier

We now bound from below the cost of the *input* to Euler's method. The model is the natural one: a search that walks the smaller part upward, $1, 2, 3, \dots$, testing at each step whether $N - a^2$ is a perfect square. Its cost is the depth it must reach. The theorem below bounds that depth for *any* procedure that identifies both representations by their smaller parts, so it applies to any implementation, sieved or not.

**Theorem 7.1 (Quartic barrier, sorted form).** *Let $0 \le a \le b$, $0 \le c \le d$ with*
$$a^2+b^2 = c^2+d^2 = N \quad\text{and}\quad d < b .$$
*Then $2N < c^4$.*

*Proof.* Since $d < b$ and both are integers, $b \ge d+1$. From $a^2+b^2 = c^2+d^2$,
$$c^2 = a^2 + b^2 - d^2 \;\ge\; b^2-d^2 \;\ge\; (d+1)^2 - d^2 = 2d+1 .$$
Squaring, $c^4 \ge (2d+1)^2 = 4d^2 + 4d + 1 > 4d^2$. On the other hand $c \le d$ gives
$$2N = 2c^2 + 2d^2 \le 4d^2 .$$
Chaining, $2N \le 4d^2 < c^4$. $\square$

**Theorem 7.2 (Gap-refined barrier).** *Under the same sorted hypotheses, if $d + k \le b$ for some integer $k > 0$, then*
$$2k^2 N < c^4 .$$

*Proof.* Now $b \ge d+k$, so $c^2 \ge b^2 - d^2 \ge (d+k)^2 - d^2 = 2kd + k^2 > 0$. Squaring,
$$c^4 \;\ge\; (2kd+k^2)^2 \;=\; 4k^2d^2 + 4k^3 d + k^4 \;>\; 4k^2 d^2 .$$
And $N \le 2d^2$ (from $c \le d$), so $2k^2 N \le 4k^2 d^2 < c^4$. $\square$

**Corollary 7.3 (Three representations).** *If $N$ has three representations in sorted form with strictly decreasing large parts $b_3 < b_2 < b_1$, then $8N < a_3^4$, where $a_3$ is the small part of the shallowest one.*

*Proof.* $b_3 + 2 \le b_1$, so Theorem 7.2 with $k=2$ gives $8N < a_3^4$. $\square$

The barrier therefore grows *quadratically* in the number of representations demanded.

**Theorem 7.4 (Symmetrised form).** *If $(a,b)$ and $(c,d)$ are essentially distinct representations of $N$ with non-negative parts, sorted, then*
$$2N < \max(a,c)^4 .$$

*Proof.* Essential distinctness forces $b \neq d$ (if $b = d$ then $a^2 = c^2$ and, with non-negative parts, the representations coincide). Trichotomy: if $d<b$ apply Theorem 7.1 to get $2N<c^4 \le \max(a,c)^4$; if $b<d$ apply it with the roles reversed. $\square$

**Theorem 7.5 (Search lower bound).** *Let $a,b,c,d > 0$ with $a^2+b^2 = c^2+d^2 = N$ and the two representations essentially distinct. If $t$ is a bound with*
$$\min(a,b) \le t \quad\text{and}\quad \min(c,d) \le t,$$
*then $2N < t^4$. Equivalently, any search that has located the smaller part of each representation has run past $(2N)^{1/4}$.*

*Proof.* Apply Theorem 7.4 to the sorted forms, in each of the four order cases; it yields $2N < \max(\min(a,b), \min(c,d))^4$. Since that maximum is $\le t$ and non-negative, $2N < t^4$. $\square$

Note the strength of the hypotheses: nothing about $N$, nothing about primality, no averaging over an instance distribution. Two distinct lattice points on the circle $x^2+y^2=N$ simply cannot both lie near the axes.

### 7.1 Assembling the comparison

**Theorem 7.6 (Euler loses on balanced instances).** *Let $p \neq q$ be primes with $p \equiv q \equiv 1 \pmod 4$, midpoint $u = (p+q)/2$ and half-gap $v = (q-p)/2 > 0$, and suppose the pair is balanced in the exact sense $v^2 < 2u$. Then:*

1. *Fermat's difference-of-squares scan succeeds on its **first** trial: $\lfloor \sqrt{pq}\rfloor + 1 = u$; and*
2. *the semiprime $pq$ has exactly two essentially distinct representations $(A,B)$, $(C,D)$ in positive integers, and any search bound $t$ with $\min(A,B) \le t$ and $\min(C,D)\le t$ satisfies*
$$2pq < t^4 .$$

*Proof.* Part 1 is Theorem 6.3. Part 2 combines Theorem 4.4 (existence and distinctness) with Theorem 7.5. $\square$

Since Euler's method must run the representation search to completion — twice over, in the sense that it needs *both* representations before it can do anything — the constant-factor loss on the balanced side is forced by Theorem 7.6, not inherited from a sampling choice.

**Example 7.7 (Non-vacuity).** $N = 13 \cdot 17 = 221$ is balanced: $u = 15$, $v = 2$, $v^2 = 4 < 30 = 2u$. Fermat's first trial $s = \lfloor\sqrt{221}\rfloor + 1 = 15$ gives $15^2 - 221 = 4 = 2^2$: one step. The representations are $221 = 5^2+14^2 = 10^2+11^2$; the larger of the two small parts is $10$, and indeed $2\cdot 221 = 442 < 10^4$, consistent with the barrier's floor $(442)^{1/4} \approx 4.585$.

---

## 8. The numerical picture

The theorems above make three quantitative predictions; each is confirmed by direct computation.

**Eligibility is exactly the $(1,1)$ cell.** Enumerating all semiprimes $pq$ with $p<q$ odd primes below a bound and tabulating by $(p \bmod 4, q \bmod 4)$, the count of normalised representations is $2$ in every instance of the $(1,1)$ cell and $0$ in every instance of the $(1,3)$ and $(3,3)$ cells, with no exceptions. The empirical density of primes $\equiv 1 \bmod 4$ among odd primes below $2\cdot 10^5$ is $0.4992$, giving a predicted eligible fraction of $0.2492$ against the limiting value $1/4 = 0.2500$.

**Extraction never fails.** Across large batches of eligible semiprimes, drawn both synthetically (build $N$ from two known primes) and by search, the combination step returns a proper nontrivial divisor in every instance, and the two gcds multiply to $N$ in every instance. This is not a statistical statement — Theorem 3.5 guarantees it — but the agreement confirms that the hypotheses have been stated correctly. The identities $AD-BC = 2efq$ and $AD+BC = 2ghp$ of Lemma 5.1 hold exactly on every tested pair, and consequently the extracted primes are the predicted ones.

**Cost.** On randomly drawn eligible semiprimes, the representation search costs a small multiple of one Fermat scan; because Euler needs both representations, the end-to-end comparison is worse again, with a median in the single-digit-to-low-double-digit multiples of Fermat and a heavy upper tail. The tail is not noise: it is exactly the balanced corner isolated by Theorem 7.6. There, Fermat terminates in one step while the representation search is bounded below by $(2N)^{1/4}$ — for $N = 10009 \times 10037 \approx 10^8$, Fermat halts immediately while the representation search must descend to depth $4867$, a ratio unbounded as $N$ grows.

Precise multipliers depend on the instance family and on implementation details of the representation search; the quartic barrier does not. It is the instance-independent statement, and it is the one that settles the comparison.

---

## 9. Discussion

### 9.1 What the results say about the method

The three faces separate cleanly.

*Correctness is not the problem.* Theorem 3.5 is as strong as one could wish: unconditional, boundary-inclusive, and — on the canonical pair — deterministic down to naming which prime each gcd returns (Theorem 5.2). If one is *given* two representations, the method is optimal: two gcds and done.

*Eligibility is a hard quarter.* Theorem 4.5 shows this is not a soft density statement but an exact classification by residue class, with the representation count pinned at exactly two (Theorem 4.4). There is no "mostly works" regime and no tuning that enlarges the class.

*Cost is where the method dies.* And it dies for a structural reason. Theorem 7.5 is a lower bound on *any* procedure that must see the smaller parts of two representations. One cannot engineer around it with a better sieve or a smarter enumeration order, because it constrains the target set, not the search strategy.

### 9.2 The geometric reading

Theorem 7.1 is a repulsion statement for lattice points on a circle. Parameterise a representation by its small part; a representation with small part $a$ sits at angle $\arcsin(a/\sqrt N)$ from the axis. The barrier says two distinct lattice points on the circle of radius $\sqrt N$ cannot both lie within angle $\approx (2N)^{1/4}/\sqrt N = (2/N)^{1/4}$ of the axis. The gap-refined Theorem 7.2 quantifies this: pushing the large parts $k$ apart pushes the shallower small part out by a factor $\sqrt k$.

This is the same phenomenon that makes lattice-point counting on circles delicate, seen from the algorithmic side. It is worth emphasising that the proof is entirely elementary — integrality of $b - d \ge 1$ is the only "hard" input — and yet it is exactly the statement needed to close the cost question.

### 9.3 Relation to the difference-of-squares route

Fermat's method and Euler's method are both driven by a factorisation of the form "combine two quadratic representations". Fermat's succeeds when the factors are close; the representation route is indifferent to the gap but expensive to feed. Theorems 6.3 and 7.6 show these two profiles are *anti-correlated in the worst possible way*: the regime in which Fermat is instantaneous is precisely a regime in which the representation route pays a quartic-depth toll.

There is no complementarity to exploit. On the unbalanced side, where Fermat's scan is long, the representation search is also long — it too must reach $(2N)^{1/4}$ before it can find both. So the representation route offers no regime of advantage over the classical scan; it is a known method with worse constants, and the constants are now proved rather than measured.

### 9.4 Limitations

The cost lower bound is stated for searches that locate representations by their small parts, which is the natural formulation for a scan. It does *not* rule out obtaining representations by some entirely different route — for instance by first factoring $N$ (circular), or via Cornacchia's algorithm applied to a known square root of $-1$ modulo each prime factor (also circular). What Theorem 7.5 says is that within the search paradigm the method is bounded below by $(2N)^{1/4}$, and that this bound is achieved on exactly the instances where the competitor is free.

Likewise the density statement of Corollary 4.6 is a statement about independent draws from the odd primes; a cryptographic modulus is not drawn that way, but the residue-class classification of Theorem 4.5 is instance-by-instance exact regardless.

---

## 10. Future directions

Several threads remain open.

**Beyond semiprimes.** Theorems 3.5 and 7.5 are unconditional on the structure of $N$; only the counting theory of Section 4 is semiprime-specific. Extending the exact eligibility classification to $N$ with $k$ prime factors — where the representation count is $2^{k-1}$ for squarefree $N$ all of whose prime factors are $\equiv 1 \bmod 4$ — should combine with Corollary 7.3 to give a barrier of the form $c \gg (2^{k}N)^{1/4}$ for collecting all $2^{k-1}$ representations.

**Sharpening the barrier.** The proof of Theorem 7.1 discards the term $a^2$ and the slack $4d+1$. The measured depths (e.g. $4867$ against a floor of $119$ for $N \approx 10^8$) suggest the truth is nearer $N^{1/2}$ on average, since the small parts of a random eligible representation are typically of order $\sqrt N$. A matching *typical-case* lower bound — as opposed to the present worst-case-proof, all-instance guarantee — would complete the picture.

**The class map as a Frobenius invariant.** Theorem 4.7 and Corollary 4.8 identify each class bit with a choice of Gaussian prime. The natural next step is to phrase the whole class map as a homomorphism from the representation set to the ideal class data of $\mathbb{Z}[i]$-modules over $\mathbb{Z}[i]/(N)$, and to ask what the analogous statement is over $\mathbb{Z}[\sqrt{-d}]$ for other discriminants, where the class group is nontrivial and the count is governed by genus theory rather than by a power of two.

**Other quadratic forms.** Euler's identity is the norm form $x^2+y^2$. The same rigidity argument should run for $x^2 + dy^2$ with $d$ such that the form is the principal form of a one-class discriminant, giving an extraction theorem and, presumably, a corresponding quartic barrier. Where the class number exceeds one, "two representations by the same form" and "two representations by forms in the same genus" split apart, and the extraction step may fail in an interesting way.

**Algorithmic corollaries.** The deterministic form (Theorem 5.2) says which prime the subtractive branch returns as a function of the sign of $BC$. If a partial representation is known — for instance one representation plus a congruential constraint on the second — this may allow a *targeted* second search that beats the generic scan, though Theorem 7.5 caps any such gain at the $(2N)^{1/4}$ floor.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Rigidity | $ad=bc$ and $ac+bd = a^2+b^2 > 0$ force $(c,d)=(a,b)$ |
| Extraction | Essentially distinct representations $\Rightarrow 1 < \gcd(ad-bc,N)<N$, unconditionally |
| Closed cone | Same, with parts merely $\ge 0$ |
| Prime uniqueness | A prime has at most one representation up to order |
| Paired gcds | $\gcd(ad-bc,N)\cdot\gcd(ad+bc,N)=pq$ for $N=pq$, $p\neq q$ |
| Exact cross-terms | $AD-BC = 2efq$, $AD+BC = 2ghp$ on the canonical pair |
| Determinism | $\gcd(AD-BC,N)=q$ and $\gcd(AD+BC,N)=p$ exactly |
| Eligibility | Two essentially distinct representations of $pq$ exist iff $p\equiv q\equiv 1 \bmod 4$ |
| Exact count | In that case exactly two; eligible fraction of draws exactly $1/4$ |
| Gaussian bridge | $(e+fi)\mid(a+bi) \iff p \mid af-be$; exactly one conjugate divides |
| Fermat criterion | First trial suffices iff $(q-p)^2 < 4(p+q)$ |
| Fermat scan length | $\frac{(q-p)^2}{8\max(p,q)} \le \frac{p+q}{2}-\sqrt{pq} \le \frac{(q-p)^2}{8\sqrt{pq}}$ |
| Quartic barrier | Reaching both small parts requires $2N<t^4$ |
| Gap refinement | Large parts $k$ apart $\Rightarrow 2k^2N<c^4$; three representations $\Rightarrow 8N<a_3^4$ |
| Euler loses | On balanced eligible semiprimes: Fermat halts in one step, representation route must pass $(2N)^{1/4}$ twice |
